extern crate glium;
use glium::{glutin, Surface};
use glium::glutin::GlContext;
use glium::glutin::dpi::*;

#[derive(Copy, Clone)]
pub struct Vertex {
    position: [f32; 3],
    coord: [f32; 2]
}

pub struct Application
{
    display:glium::Display,
    vertex_buffer:glium::VertexBuffer<Vertex>,
    indice_buffer:glium::index::IndexBuffer<u16>,
    program:glium::Program,
    events_loop:glutin::EventsLoop
}

const SCREEN_WIDTH: f64 = 640.0;
const SCREEN_HEIGHT: f64 = 360.0;

impl Application{
    pub fn new()->Application{
        let mut events_loop = glutin::EventsLoop::new();
        let window = glutin::WindowBuilder::new();
        let context = glutin::ContextBuilder::new();
        let display = glium::Display::new(window, context, &events_loop).unwrap();

        implement_vertex!(Vertex, position, coord);

        let vertex1 = Vertex { position:[1.0, 1.0, 0.0], coord:[1.0 * SCREEN_WIDTH as f32, 1.0 * SCREEN_HEIGHT as f32]};
        let vertex2 = Vertex { position:[1.0, -1.0, 0.0], coord:[1.0 * SCREEN_WIDTH as f32, 0.0]};
        let vertex3 = Vertex { position:[-1.0, -1.0, 0.0,], coord:[0.0, 0.0]};
        let vertex4 = Vertex { position:[-1.0,1.0, 0.0], coord:[0.0, 1.0 * SCREEN_HEIGHT as f32]};
        
        let indice_array : [u16; 6] = [0, 1, 3, 1, 2, 3];

        let shape = vec![vertex1, vertex2, vertex3, vertex4];
        let vertex_buffer = glium::VertexBuffer::new(&display, &shape).unwrap();
        let indice_buffer = glium::index::IndexBuffer::new(&display, glium::index::PrimitiveType::TrianglesList, &indice_array).unwrap();
        
        let vertex_shader_src = r#"
        #version 140
        in vec3 position;
        in vec2 coord;
        void main() {
            gl_Position = vec4(position, 1.0);
        }
        "#;

        let fragment_shader_src = r#"
        #version 140
        out vec4 color;
        void main() {
            color = vec4(1.0, 0.0, 0.0, 1.0);
        }
        "#;

        let program = glium::Program::from_source(&display, vertex_shader_src, fragment_shader_src, None).unwrap();
        return Application{display:display, events_loop:events_loop, vertex_buffer:vertex_buffer, indice_buffer:indice_buffer, program:program};
    }

    pub fn update(&mut self){
        let mut closed = false;
        while !closed {
            //Fix Mac Mojave Bug
            let gl_window = self.display.gl_window();
            gl_window.resize(PhysicalSize::new(SCREEN_WIDTH, SCREEN_HEIGHT));

            let mut target = self.display.draw();
            target.clear_color(0.0, 0.0, 1.0, 1.0);
            target.draw(&self.vertex_buffer, &self.indice_buffer, &self.program, &glium::uniforms::EmptyUniforms,
                        &Default::default()).unwrap();
            target.finish().unwrap();
            
            self.events_loop.poll_events(|event| {
                match event {
                    glutin::Event::WindowEvent { event, .. } => match event {
                        glutin::WindowEvent::CloseRequested => closed = true,
                        _ => ()
                    },
                    _ => (),
                }
            });
        }
    }
}