const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const harfbuzz_enabled = b.option(bool, "enable-harfbuzz", "Use HarfBuzz to improve text shaping") orelse false;

    const upstream = b.dependency("sdl_ttf", .{});

    const lib = b.addStaticLibrary(.{
        .name = "SDL2_ttf",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFile(.{ .file = upstream.path("SDL_ttf.c") });
    lib.linkLibC();

    if (harfbuzz_enabled) {
        const harfbuzz_dep = b.dependency("harfbuzz", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(harfbuzz_dep.artifact("harfbuzz"));
        lib.defineCMacro("TTF_USE_HARFBUZZ", null);
    }

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(freetype_dep.artifact("freetype"));

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_lib = sdl_dep.artifact("SDL2");
    lib.linkLibrary(sdl_lib);
    if (sdl_lib.installed_headers_include_tree) |tree|
        lib.addIncludePath(tree.getDirectory().path(b, "SDL2"));

    lib.installHeader(upstream.path("SDL_ttf.h"), "SDL2/SDL_ttf.h");

    b.installArtifact(lib);
}
