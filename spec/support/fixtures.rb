module SpecHelpers

  def interpolate_erb(path, options)
    template = ERB.new(File.read(path))
    struct = OpenStruct.new(options).instance_eval { binding }
    template.result(struct)
  end

  def interpolate_and_compile_solidity(files, options, compiler_params)
    interpolated_options = {}
    Array.wrap(files).each do |path|
      full_path = "spec/fixtures/ethereum/solidity/#{path}.erb"
      solidity = interpolate_erb(full_path, options)
      interpolated_options[path] = solidity
    end
    ethereum.solidity.compile compiler_params.merge(interpolated_options)
  end

end
