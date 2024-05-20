def _ido_binary_c_file_impl(ctx):
    new = ctx.actions.declare_file(ctx.label.name + ".c")
    x = ""
    if ctx.attr.conservative:
        x = "--conservative"
    ctx.actions.run_shell(
        tools = [ctx.executable._recomp],
        inputs = [ctx.file.srcbin],
        outputs = [new],
        command = "%s %s %s > %s" % (ctx.executable._recomp.path, ctx.file.srcbin.path, x, new.path),
    )
    return [DefaultInfo(files = depset([new]))]

ido_binary_c_file = rule(
    implementation = _ido_binary_c_file_impl,
    attrs = {
        "_recomp": attr.label(
            default = Label("//:recomp"),
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "srcbin": attr.label(
            allow_single_file = True,
        ),
        "conservative": attr.bool(),
    },
)

def ido_binary(name, srcbin, conservative, stdlib):
    ido_binary_c_file(name = name + "_c", srcbin = srcbin, conservative = conservative)
    native.cc_binary(name = name, srcs = [":" + name + "_c"], deps = [stdlib])
