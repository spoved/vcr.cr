require "../vcr"

module VCR::Methods
  def load_cassette(cassette, *args, &block)
    VCR.use_cassette(cassette, *args) do
      block.call
    end
  end

  def load_cassette(cassette, *args)
    VCR.use_cassette(cassette, *args)
  end
end

include VCR::Methods
