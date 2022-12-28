export ImageLayer

mutable struct ImageLayer <: AbstractLayer
    canvas::Union{Array{C}, CuArray{C}, ROCArray{C}} where C <: RGBA
    position::Tuple
    world_size::Tuple
    ppu::Number
    params::NamedTuple
    postprocessing_steps::Vector{APP} where APP <: AbstractPostProcess
end

# dynamically sets ppu based on world_size
function ImageLayer(img;
                    postprocessing_steps = Vector{AbstractPostProcess}([]),
                    position = (0.0, 0.0),
                    ppu = 1200,
                    ArrayType = Array,
                    FloatType = Float32,
                    numcores = 4,
                    numthreads = 256) where CT <: Union{RGB, RGBA}

    world_size = (size(img)[1]/ppu, size(img)[2]/ppu)

    return ImageLayer(img, position, world_size, ppu,
                      params(ImageLayer;
                             ArrayType = ArrayType,
                             FloatType = FloatType,
                             numcores = numcores,
                             numthreads = numthreads),
                      postprocessing_steps)

end

function ImageLayer(filename::String;
                    postprocessing_steps = Vector{AbstractPostProcess}([]),
                    position = (0.0, 0.0),
                    ppu = 1,
                    ArrayType = Array,
                    FloatType = Float32,
                    numcores = 4,
                    numthreads = 256) where CT <: Union{RGB, RGBA}

    img = load(filename)
    return ImageLayer(img;
                      position = position,
                      ppu = ppu,
                      ArrayType = ArrayType,
                      FloatType = FloatType,
                      numcores = numcores,
                      numthreads = numthreads,
                      postprocessing_steps = postprocessing_steps)

end
