extern crate gl;
use self::gl::types::*;

extern crate glutin;

use std::mem;
use std::os::raw::c_void;
use std::ptr;
use std::ffi::CStr;
use std::time::{Duration, Instant};

use glutin::dpi::*;
use glutin::GlContext;

mod shader;
use shader::Shader;

extern crate notify;

use notify::{RecommendedWatcher, Watcher, RecursiveMode};
use std::thread;
use std::sync::mpsc;
use std::sync::{Mutex, Arc};

// settings
const SCREEN_WIDTH: f64 = 640.0;
const SCREEN_HEIGHT: f64 = 360.0;

macro_rules! c_str {
    ($literal:expr) => {
        CStr::from_bytes_with_nul_unchecked(concat!($literal, "\0").as_bytes())
    }
}

fn main() {
    let mut events_loop = glutin::EventsLoop::new();
    let window = glutin::WindowBuilder::new()
        .with_title("Shadertoy Playground")
        .with_dimensions(LogicalSize::new(SCREEN_WIDTH, SCREEN_HEIGHT));
    let context = glutin::ContextBuilder::new().with_vsync(true);
    let gl_window = glutin::GlWindow::new(window, context, &events_loop).unwrap();

    unsafe {
        gl_window.make_current().unwrap();
    }

    {
        gl::load_with(|symbol| gl_window.get_proc_address(symbol) as *const _);
    }

    let (mut shader, vbo, vao, ebo) = unsafe {
        let shader = Shader::new("src/vert.glsl", "playground.glsl"); // you can name your shader files however you like)

        // set up vertex data (and buffer(s)) and configure vertex attributes
        // ------------------------------------------------------------------
        // HINT: type annotation is crucial since default for float literals is f64
        let vertices: [f32; 20] = [
            1.0, 1.0, 0.0, 1.0 * SCREEN_WIDTH as f32, 1.0 * SCREEN_HEIGHT as f32,
            1.0, -1.0, 0.0, 1.0 * SCREEN_WIDTH as f32, 0.0,
            -1.0, -1.0, 0.0, 0.0, 0.0, 
            -1.0,1.0, 0.0, 0.0, 1.0 * SCREEN_HEIGHT as f32,
        ];

        let indices = [0, 1, 3, 1, 2, 3];

        let (mut vbo, mut vao, mut ebo) = (0, 0, 0);
        gl::GenVertexArrays(1, &mut vao);
        gl::GenBuffers(1, &mut vbo);
        gl::GenBuffers(1, &mut ebo);
        // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
        gl::BindVertexArray(vao);

        gl::BindBuffer(gl::ARRAY_BUFFER, vbo);
        gl::BufferData(
            gl::ARRAY_BUFFER,
            (vertices.len() * mem::size_of::<GLfloat>()) as GLsizeiptr,
            &vertices[0] as *const f32 as *const c_void,
            gl::STATIC_DRAW,
        );

        gl::BindBuffer(gl::ELEMENT_ARRAY_BUFFER, ebo);
        gl::BufferData(
            gl::ELEMENT_ARRAY_BUFFER,
            (indices.len() * mem::size_of::<GLfloat>()) as GLsizeiptr,
            &indices[0] as *const i32 as *const c_void,
            gl::STATIC_DRAW,
        );

        let stride = 5 * mem::size_of::<GLfloat>() as GLsizei;
        // position attribute
        gl::VertexAttribPointer(0, 3, gl::FLOAT, gl::FALSE, stride, ptr::null());
        gl::EnableVertexAttribArray(0);
        // coord attribute
        gl::VertexAttribPointer(
            1,
            2,
            gl::FLOAT,
            gl::FALSE,
            stride,
            (3 * mem::size_of::<GLfloat>()) as *const c_void,
        );
        gl::EnableVertexAttribArray(1);

        (shader, vbo, vao, ebo)
    };

    let mut running = true;
    let timer = Instant::now();
    let mut current_time;

    let (mut mouse_x, mut mouse_y):(f64, f64) = (0.0, 0.0);
    let mut mouse_left_pressed = false;
    
    let should_update_shader = Arc::new(Mutex::new(0));

    let should_update_shader_copy = Arc::clone(&should_update_shader);
    thread::spawn(move || {
        let (tx, rx) = mpsc::channel();
        // Automatically select the best implementation for your platform.
        // You can also access each implementation directly e.g. INotifyWatcher.
        let mut watcher: RecommendedWatcher = Watcher::new(tx, Duration::from_secs(2)).unwrap();

        // Add a path to be watched. All files and directories at that path and
        // below will be monitored for changes.
        watcher.watch("playground.glsl", RecursiveMode::NonRecursive).unwrap();

        loop
        {
            match rx.recv() {
                Ok(_event) => {
                    let mut should_update_shader_value = should_update_shader_copy.lock().unwrap();
                    *should_update_shader_value = 1;
                    println!("Shader Changed");
                    //ourShader.update("src/vert.glsl", "playground.glsl")
                    },
                Err(_event) => {
                    println!("Error");
                },
            }
        }
    });

    while running {
        if *should_update_shader.lock().unwrap() == 1
        {
            *should_update_shader.lock().unwrap() = 0;
            shader.update("src/vert.glsl", "playground.glsl");
        }
        events_loop.poll_events(|event| match event {
            glutin::Event::WindowEvent { event, .. } => match event {
                glutin::WindowEvent::CloseRequested => running = false,
                glutin::WindowEvent::Resized(logical_size) => {
                    let dpi_factor = gl_window.get_hidpi_factor();
                    gl_window.resize(logical_size.to_physical(dpi_factor));
                },
                glutin::WindowEvent::CursorMoved{device_id:_, position, modifiers:_}=>{
                    mouse_x = position.x;
                    mouse_y = position.y;
                },
                glutin::WindowEvent::MouseInput{device_id:_, button, state, modifiers:_}=>{
                    if button == glutin::MouseButton::Left && state == glutin::ElementState::Pressed
                    {
                        mouse_left_pressed = true;
                        println!("mouse press true");
                    }

                    if button == glutin::MouseButton::Left && state == glutin::ElementState::Released
                    {
                        mouse_left_pressed = false;
                        println!("mouse press false");
                    }
                },
                _ => (),
            },
            _ => (),
        });

        //To Fix Mojave Bug
        gl_window.resize(PhysicalSize::new(SCREEN_WIDTH, SCREEN_HEIGHT));
        
        current_time = timer.elapsed();
        let time_in_s = current_time.as_secs() as f32 + (current_time.subsec_micros() as f32 /1000000.0 as f32) as f32;
        //println!("current time is {:.3}", time_in_s);
        //info("time is {}", time_in_s);
        unsafe {
            gl::ClearColor(0.0, 0.0, 0.0, 1.0);
            gl::Clear(gl::COLOR_BUFFER_BIT);

            shader.useProgram();
            shader.setVec2(c_str!("iResolution"), SCREEN_WIDTH as f32, SCREEN_HEIGHT as f32);
            if mouse_left_pressed
            {
                shader.setVec2(c_str!("iMouse"), mouse_x as f32, mouse_y as f32);
            }
            //println!("current mouse x is {:.3} y is {:.3}", mouse_x, mouse_y);
            shader.setFloat(c_str!("iTime"), time_in_s as f32);

            gl::BindVertexArray(vao);
            gl::DrawElements(gl::TRIANGLES, 6, gl::UNSIGNED_INT, ptr::null());
        }

        gl_window.swap_buffers().unwrap();
    }
    unsafe {
        gl::DeleteVertexArrays(1, &vao);
        gl::DeleteBuffers(1, &vbo);
        gl::DeleteBuffers(1, &ebo);
    }
}
