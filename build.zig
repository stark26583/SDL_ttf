const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const harfbuzz_enabled = b.option(bool, "enable-harfbuzz", "Use HarfBuzz to improve text shaping") orelse true;

    const upstream = b.dependency("SDL_ttf", .{});

    const sdl_ttf_module = b.addModule("sdl_ttf", .{
        .target = target,
        .optimize = optimize,
    });
    sdl_ttf_module.addIncludePath(upstream.path("include"));
    sdl_ttf_module.addIncludePath(upstream.path("src"));
    sdl_ttf_module.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = srcs,
    });

    if (harfbuzz_enabled) {
        const harfbuzz_dep = b.dependency("harfbuzz", .{
            .target = target,
            .optimize = optimize,
        });
        sdl_ttf_module.linkLibrary(harfbuzz_dep.artifact("harfbuzz"));
        sdl_ttf_module.addCMacro("TTF_USE_HARFBUZZ", "1");
    }

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });
    sdl_ttf_module.linkLibrary(freetype_dep.artifact("freetype"));
}

const srcs: []const []const u8 = &.{
    "SDL_gpu_textengine.c",
    "SDL_hashtable.c",
    "SDL_hashtable_ttf.c",
    "SDL_renderer_textengine.c",
    "SDL_surface_textengine.c",
    "SDL_ttf.c",
};
