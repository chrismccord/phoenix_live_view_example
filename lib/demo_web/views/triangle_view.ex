defmodule DemoWeb.TriangleView do
  use Phoenix.LiveView
end
#   @container_style %{
#     position: "absolute",
#     "transform-origin": "0 0",
#     left: "50%",
#     top: "50%",
#     width: "10px",
#     height: "10px",
#     background: "#eee"
#   }

#   @target_size = 25

#   def render(assigns) do
#     ~L"""
#     <style>
#       .dot{
#         position: absolute;
#         font: normal 15px sans-serif;
#         text-align: center;
#         cursor: pointer;
#       }
#     </style>

#     <%= for dot <- @dots do %>
#       <div class="dot" style="
#         background: "<%= dot.background || "#61dafb %>";
#         width: <%= dot.width %>;
#         height: <%= dot.height %>;
#         left: <%= dot.left %>;
#         top: <%= dot.top %>;
#         border-radius: <%= dot.border_radius %>px;
#         line-height: <%= dot.line_height %>px;
#       "
#       <%= dot.text %>
#     <%= end %>
#     """
#   end

#   def mount(_session, socket) do
#     socket = assign(socket, %{
#       seconds: 0,
#       elapsed: 0,
#     })
#     |> animate()
#     {:ok, socket}
#   end

#   defp animate(socket) do
#     time = rem(socket.assigns.elapsed / 1000, 10)
#     scale = 1 + (if time > 5, do: 10 - time, else: time) / 10
#     scale_x = (scale / 2.1)

#     assign(socket, %{
#       time: time, scale: scale: scale_x: scale_x
#     })
#   end

# #         render() {
# #           const seconds = this.state.seconds;
# #           const elapsed = this.props.elapsed;
# #           const t = (elapsed / 1000) % 10;
# #           const scale = 1 + (t > 5 ? 10 - t : t) / 10;
# #           const transform = "scaleX(" + (scale / 2.1) + ") scaleY(0.7) translateZ(0.1px)";
# #           return (
# #             <div style={{ ...containerStyle, transform }}>
# #               <div>
# #                 <SierpinskiTriangle x={0} y={0} s={1000}>
# #                   {this.state.seconds}
# #                 </SierpinskiTriangle>
# #               </div>
# #             </div>
# #           );
# #         }
# #       }


#   defp build_dots(socket) do
#     current_count = socket.assigns.current_count
#     for i <- 0..socket.assigns.dot_count do
#       size = @target_size * 1.3

#       %{
#         text: current_count,
#         hover: false,
#         style:
#           merge_styles(%{
#             width: size,
#             height: size,
#             left: x,
#             top: y,
#             border_radius: size / 2,
#             line_height: size,
#             background:
#           })
#       }
#     end
#   end

#   defp merge_styles(dot_style), Map.merge(@dot_style, dot_style)
# end

# #           return (
# #             <div style={style} onMouseEnter={() => this.enter()} onMouseLeave={() => this.leave()}>
# #               {this.state.hover ? "*" + props.text + "*" : props.text}
# #             </div>
# #           );
# #         }
# #       }

# #       function SierpinskiTriangle({ x, y, s, children }) {
# #         if (s <= targetSize) {
# #           return (
# #             <Dot
# #               x={x - (targetSize / 2)}
# #               y={y - (targetSize / 2)}
# #               size={targetSize}
# #               text={children}
# #             />
# #           );
# #           return r;
# #         }
# #         var newSize = s / 2;
# #         var slowDown = true;
# #         if (slowDown) {
# #           var e = performance.now() + 0.8;
# #           while (performance.now() < e) {
# #             // Artificially long execution time.
# #           }
# #         }

# #         s /= 2;

# #         return [
# #           <SierpinskiTriangle x={x} y={y - (s / 2)} s={s}>
# #             {children}
# #           </SierpinskiTriangle>,
# #           <SierpinskiTriangle x={x - s} y={y + (s / 2)} s={s}>
# #             {children}
# #           </SierpinskiTriangle>,
# #           <SierpinskiTriangle x={x + s} y={y + (s / 2)} s={s}>
# #             {children}
# #           </SierpinskiTriangle>,
# #         ];
# #       }
# #       SierpinskiTriangle.shouldComponentUpdate = function(oldProps, newProps) {
# #         var o = oldProps;
# #         var n = newProps;
# #         return !(
# #           o.x === n.x &&
# #           o.y === n.y &&
# #           o.s === n.s &&
# #           o.children === n.children
# #         );
# #       };

# #       class ExampleApplication extends React.Component {
# #         constructor() {
# #           super();
# #           this.state = { seconds: 0 };
# #           this.tick = this.tick.bind(this);
# #         }
# #         componentDidMount() {
# #           this.intervalID = setInterval(this.tick, 1000);
# #         }
# #         tick() {
# #           ReactDOMFiber.unstable_deferredUpdates(() =>
# #             this.setState(state => ({ seconds: (state.seconds % 10) + 1 }))
# #           );
# #         }
# #         componentWillUnmount() {
# #           clearInterval(this.intervalID);
# #         }
# #         render() {
# #           const seconds = this.state.seconds;
# #           const elapsed = this.props.elapsed;
# #           const t = (elapsed / 1000) % 10;
# #           const scale = 1 + (t > 5 ? 10 - t : t) / 10;
# #           const transform = "scaleX(" + (scale / 2.1) + ") scaleY(0.7) translateZ(0.1px)";
# #           return (
# #             <div style={{ ...containerStyle, transform }}>
# #               <div>
# #                 <SierpinskiTriangle x={0} y={0} s={1000}>
# #                   {this.state.seconds}
# #                 </SierpinskiTriangle>
# #               </div>
# #             </div>
# #           );
# #         }
# #       }

# #       var start = new Date().getTime();
# #       function update() {
# #         ReactDOMFiber.render(
# #           <ExampleApplication elapsed={new Date().getTime() - start} />,
# #           document.getElementById("container")
# #         );
# #         requestAnimationFrame(update);
# #       }
# #       requestAnimationFrame(update);

# # end

# # # <!DOCTYPE html>
# # # <html style="width: 100%; height: 100%; overflow: hidden">
# # #   <head>
# # #     <meta charset="utf-8">
# # #     <title>Fiber Example</title>
# # #     <link rel="stylesheet" href="css/base.css" />
# # #   </head>
# # #   <body>
# # #     <h1>Fiber Example</h1>
# # #     <div id="container">
# # #       <p>
# # #         To install React, follow the instructions on
# # #         <a href="https://github.com/facebook/react/">GitHub</a>.
# # #       </p>
# # #       <p>
# # #         If you can see this, React is <strong>not</strong> working right.
# # #         If you checked out the source from GitHub make sure to run <code>grunt</code>.
# # #       </p>
# # #     </div>
# # #     <script src="js/react.js"></script>
# # #     <script src="js/react-dom-fiber.js"></script>
# # #     <script src="https://cdnjs.cloudflare.com/ajax/libs/babel-core/5.8.24/browser.min.js"></script>
# # #     <script type="text/babel">
# # #       var dotStyle = {
# # #         position: "absolute",
# # #         background: "#61dafb",
# # #         font: "normal 15px sans-serif",
# # #         textAlign: "center",
# # #         cursor: "pointer",
# # #       };

# # #       var containerStyle = {
# # #         position: "absolute",
# # #         transformOrigin: "0 0",
# # #         left: "50%",
# # #         top: "50%",
# # #         width: "10px",
# # #         height: "10px",
# # #         background: "#eee",
# # #       };

# # #       var targetSize = 25;

# # #       class Dot extends React.Component {
# # #         constructor() {
# # #           super();
# # #           this.state = { hover: false };
# # #         }
# # #         enter() {
# # #           this.setState({
# # #             hover: true
# # #           });
# # #         }
# # #         leave() {
# # #           this.setState({
# # #             hover: false
# # #           });
# # #         }
# # #         render() {
# # #           var props = this.props;
# # #           var s = props.size * 1.3;
# # #           var style = {
# # #             ...dotStyle,
# # #             width: s + "px",
# # #             height: s + "px",
# # #             left: (props.x) + "px",
# # #             top: (props.y) + "px",
# # #             borderRadius: (s / 2) + "px",
# # #             lineHeight: (s) + "px",
# # #             background: this.state.hover ? "#ff0" : dotStyle.background
# # #           };
# # #           return (
# # #             <div style={style} onMouseEnter={() => this.enter()} onMouseLeave={() => this.leave()}>
# # #               {this.state.hover ? "*" + props.text + "*" : props.text}
# # #             </div>
# # #           );
# # #         }
# # #       }

# # #       function SierpinskiTriangle({ x, y, s, children }) {
# # #         if (s <= targetSize) {
# # #           return (
# # #             <Dot
# # #               x={x - (targetSize / 2)}
# # #               y={y - (targetSize / 2)}
# # #               size={targetSize}
# # #               text={children}
# # #             />
# # #           );
# # #           return r;
# # #         }
# # #         var newSize = s / 2;
# # #         var slowDown = true;
# # #         if (slowDown) {
# # #           var e = performance.now() + 0.8;
# # #           while (performance.now() < e) {
# # #             // Artificially long execution time.
# # #           }
# # #         }

# # #         s /= 2;

# # #         return [
# # #           <SierpinskiTriangle x={x} y={y - (s / 2)} s={s}>
# # #             {children}
# # #           </SierpinskiTriangle>,
# # #           <SierpinskiTriangle x={x - s} y={y + (s / 2)} s={s}>
# # #             {children}
# # #           </SierpinskiTriangle>,
# # #           <SierpinskiTriangle x={x + s} y={y + (s / 2)} s={s}>
# # #             {children}
# # #           </SierpinskiTriangle>,
# # #         ];
# # #       }
# # #       SierpinskiTriangle.shouldComponentUpdate = function(oldProps, newProps) {
# # #         var o = oldProps;
# # #         var n = newProps;
# # #         return !(
# # #           o.x === n.x &&
# # #           o.y === n.y &&
# # #           o.s === n.s &&
# # #           o.children === n.children
# # #         );
# # #       };

# # #       class ExampleApplication extends React.Component {
# # #         constructor() {
# # #           super();
# # #           this.state = { seconds: 0 };
# # #           this.tick = this.tick.bind(this);
# # #         }
# # #         componentDidMount() {
# # #           this.intervalID = setInterval(this.tick, 1000);
# # #         }
# # #         tick() {
# # #           ReactDOMFiber.unstable_deferredUpdates(() =>
# # #             this.setState(state => ({ seconds: (state.seconds % 10) + 1 }))
# # #           );
# # #         }
# # #         componentWillUnmount() {
# # #           clearInterval(this.intervalID);
# # #         }
# # #         render() {
# # #           const seconds = this.state.seconds;
# # #           const elapsed = this.props.elapsed;
# # #           const t = (elapsed / 1000) % 10;
# # #           const scale = 1 + (t > 5 ? 10 - t : t) / 10;
# # #           const transform = "scaleX(" + (scale / 2.1) + ") scaleY(0.7) translateZ(0.1px)";
# # #           return (
# # #             <div style={{ ...containerStyle, transform }}>
# # #               <div>
# # #                 <SierpinskiTriangle x={0} y={0} s={1000}>
# # #                   {this.state.seconds}
# # #                 </SierpinskiTriangle>
# # #               </div>
# # #             </div>
# # #           );
# # #         }
# # #       }

# # #       var start = new Date().getTime();
# # #       function update() {
# # #         ReactDOMFiber.render(
# # #           <ExampleApplication elapsed={new Date().getTime() - start} />,
# # #           document.getElementById("container")
# # #         );
# # #         requestAnimationFrame(update);
# # #       }
# # #       requestAnimationFrame(update);
# # #     </script>
# # #   </body>
# # # </html>
