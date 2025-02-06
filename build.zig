const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const harfbuzz_enabled = b.option(bool, "enable-harfbuzz", "Use HarfBuzz to improve text shaping") orelse true;

    const upstream = b.dependency("sdl_ttf", .{});

    const lib = b.addStaticLibrary(.{
        .name = "SDL3_ttf",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(upstream.path("include"));
    lib.addIncludePath(upstream.path("src"));
    lib.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = srcs,
    });
    lib.linkLibC();

    if (harfbuzz_enabled) {
        const harfbuzz_dep = b.dependency("harfbuzz", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(harfbuzz_dep.artifact("harfbuzz"));
        lib.root_module.addCMacro("TTF_USE_HARFBUZZ", "1");
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
    const sdl_lib = sdl_dep.artifact("SDL3");
    lib.linkLibrary(sdl_lib);

    lib.installHeadersDirectory(upstream.path("include"), "", .{});

    b.installArtifact(lib);
}

const srcs: []const []const u8 = &.{
    "SDL_gpu_textengine.c",
    "SDL_hashtable.c",
    "SDL_hashtable_ttf.c",
    "SDL_renderer_textengine.c",
    "SDL_surface_textengine.c",
    "SDL_ttf.c",
};
