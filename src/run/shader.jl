export run!

function run!(layer::ShaderLayer; diagnostic = false, frame = 0) 

    if layer.params.ArrayType <: Array
        kernel! = shader_kernel!(CPU(), layer.params.numcores)
    elseif has_cuda_gpu() && layer.params.ArrayType <: CuArray
        kernel! = shader_kernel!(CUDADevice(), layer.params.numthreads)
    elseif has_rocm_gpu() && layer.params.ArrayType <: ROCArray
        kernel! = shader_kernel!(ROCDevice(), layer.params.numthreads)
    end

    bounds = find_bounds(layer)

    println(combine(layer.shader.kwargs, layer.shader.fis))

    wait(@invokelatest kernel!(layer.canvas, bounds,
                               layer.shader.fxs,
                               combine(layer.shader.kwargs, layer.shader.fis),
                               frame,
                               ndrange = size(layer.canvas)))
end

@kernel function shader_kernel!(canvas, bounds, fxs, kwargs, frame)

    i, j = @index(Global, NTuple)
    res = @ndrange()

    @inbounds y = bounds.ymin + (i/res[1])*(bounds.ymax - bounds.ymin)
    @inbounds x = bounds.xmin + (j/res[2])*(bounds.xmax - bounds.xmin)

    color = RGBA{Float32}(0,0,0,0)

    for i = 1:length(fxs)
        @inbounds color = fxs[i](y, x, color, frame; kwargs[i]...)
    end

    @inbounds canvas[i,j] = RGBA{Float32}(color)
end
