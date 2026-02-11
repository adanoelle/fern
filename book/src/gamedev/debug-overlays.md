# Debug Overlays

Debug overlays render diagnostic information directly into the game world —
hitboxes, colliders, velocities, entity labels, and more. This chapter covers
three complementary techniques available with the Fern gamedev stack.

## ImGui ImDrawList — World-Space Debug Geometry

ImGui's `ImDrawList` API can draw arbitrary 2D primitives (lines, circles,
rects, text) into the game viewport. The trick is to create a fullscreen
transparent ImGui window and draw in world coordinates.

### Setup

```cpp
// At the start of your debug draw pass:
ImGui::SetNextWindowPos({0, 0});
ImGui::SetNextWindowSize(ImGui::GetIO().DisplaySize);
ImGui::Begin("##debug_overlay", nullptr,
    ImGuiWindowFlags_NoDecoration |
    ImGuiWindowFlags_NoBackground |
    ImGuiWindowFlags_NoInputs |
    ImGuiWindowFlags_NoNav);

ImDrawList* dl = ImGui::GetWindowDrawList();
```

### Drawing in World Space

Convert world coordinates to screen coordinates using your camera transform,
then draw:

```cpp
// Example: draw a rectangle around a collider
auto screen_min = world_to_screen(camera, body.aabb.min);
auto screen_max = world_to_screen(camera, body.aabb.max);
dl->AddRect(screen_min, screen_max, IM_COL32(0, 255, 0, 180), 0.0f, 0, 2.0f);

// Example: draw velocity vector
auto pos = world_to_screen(camera, body.position);
auto vel_end = world_to_screen(camera, body.position + body.velocity * 0.1f);
dl->AddLine(pos, vel_end, IM_COL32(255, 255, 0, 200), 2.0f);

// Example: entity label
dl->AddText(screen_min - ImVec2(0, 16), IM_COL32(255, 255, 255, 200), "Player");
```

### Useful Primitives

| Method                          | Use Case                            |
| ------------------------------- | ----------------------------------- |
| `AddRect` / `AddRectFilled`     | AABBs, hitboxes, trigger zones      |
| `AddCircle` / `AddCircleFilled` | Radii, sensor ranges                |
| `AddLine`                       | Velocity vectors, raycasts, normals |
| `AddText`                       | Entity labels, state names, values  |
| `AddPolyline`                   | Arbitrary collision shapes          |
| `AddQuadFilled`                 | Oriented bounding boxes             |

Remember to call `ImGui::End()` after drawing.

## Box2D v3 Debug Draw

Box2D v3 provides a `b2DebugDraw` struct with callback function pointers. You
implement each callback to draw with your renderer (here, ImDrawList).

### Setting Up the Callbacks

```cpp
b2DebugDraw debug_draw = b2DefaultDebugDraw();

debug_draw.drawShapes = true;
debug_draw.drawJoints = true;
debug_draw.drawAABBs = false;         // toggle as needed
debug_draw.drawMass = false;
debug_draw.drawContacts = true;
debug_draw.drawContactNormals = true;

// Assign your ImDrawList-based callbacks:
debug_draw.DrawPolygon = my_draw_polygon;
debug_draw.DrawSolidPolygon = my_draw_solid_polygon;
debug_draw.DrawCircle = my_draw_circle;
debug_draw.DrawSolidCircle = my_draw_solid_circle;
debug_draw.DrawSegment = my_draw_segment;
debug_draw.DrawPoint = my_draw_point;
debug_draw.DrawTransform = my_draw_transform;
debug_draw.DrawString = my_draw_string;

debug_draw.context = &my_render_context;  // passed to all callbacks
```

### Example Callback

```cpp
void my_draw_solid_polygon(
    b2Transform transform, const b2Vec2* vertices, int count,
    float radius, b2HexColor color, void* context)
{
    auto* ctx = static_cast<RenderContext*>(context);
    ImDrawList* dl = ctx->draw_list;

    std::vector<ImVec2> screen_verts(count);
    for (int i = 0; i < count; i++) {
        b2Vec2 world = b2TransformPoint(transform, vertices[i]);
        screen_verts[i] = world_to_screen(ctx->camera, {world.x, world.y});
    }

    ImU32 col = IM_COL32(
        (color >> 16) & 0xFF,
        (color >> 8) & 0xFF,
        color & 0xFF,
        128);

    dl->AddConvexPolyFilled(screen_verts.data(), count, col);
    dl->AddPolyline(screen_verts.data(), count, col | 0xFF000000, true, 1.5f);
}
```

### Rendering

Call `b2World_Draw(world_id, &debug_draw)` each frame when debug rendering is
active. Toggle individual flags at runtime via your ImGui debug panel.

## EnTT Entity Inspection

### Runtime Reflection with `entt::meta`

Register components for runtime inspection:

```cpp
entt::meta<Transform>()
    .type("Transform"_hs)
    .data<&Transform::x>("x"_hs)
    .data<&Transform::y>("y"_hs)
    .data<&Transform::rotation>("rotation"_hs);

entt::meta<Health>()
    .type("Health"_hs)
    .data<&Health::current>("current"_hs)
    .data<&Health::max>("max"_hs);
```

### imgui_entt_entity_editor

[imgui_entt_entity_editor](https://github.com/Green-Sky/imgui_entt_entity_editor)
is a single-header library for inspecting and editing EnTT entities in an ImGui
window. Vendor it into your project:

```cpp
#include "imgui_entt_entity_editor.hpp"

MM::EntityEditor<entt::entity> editor;

// Register component UIs (once at init):
editor.registerComponent<Transform>("Transform");
editor.registerComponent<Health>("Health");
editor.registerComponent<Sprite>("Sprite");

// In your debug UI loop:
if (selected_entity != entt::null) {
    editor.renderSimpleComboEntitySelector(registry, selected_entity);
    editor.renderEditor(registry, selected_entity);
}
```

### Tracy Zones per ECS System

Wrap each ECS system in a Tracy zone for per-system profiling:

```cpp
void physics_system(entt::registry& reg, float dt) {
    ZoneScopedN("physics_system");
    // ...
}

void render_system(entt::registry& reg) {
    ZoneScopedN("render_system");
    // ...
}
```

This gives you a clear per-system breakdown in the Tracy profiler timeline.
