RSpec.describe Profanityfilter do
  it "has a version number" do
    expect(Profanityfilter::VERSION).not_to be nil
  end

  describe 'sanitize' do
    it 'sanitizes complete sentences' do
      sanitized1 = Profanityfilter.sanitize 'This is the $h1!t'
      sanitized2 = Profanityfilter.sanitize 'Fuuck the police. shit!'
      sanitized3 = Profanityfilter.sanitize '$h i t fuuuck!'
      sanitized4 = Profanityfilter.sanitize '$ h i t head'
      expect(sanitized1).to eq 'This is the ****'
      expect(sanitized2).to eq '**** the police. ****!'
      expect(sanitized3).to eq '**** ****!'
      expect(sanitized4).to eq '**** head'
    end

    it 'works with long text and multiple profanities' do
      sentence = "Gotta fucking love this sh!t. Who gives a fuuuuck about AI when you have this c u n t. It's all about this $h!t these days. Lorem ipsum dolor sit amet fuckers!"
      expected = "Gotta ****ing love this ****. Who gives a **** about AI when you have this ****. It's all about this **** these days. Lorem ipsum dolor sit amet ****ers!"

      sanitized = Profanityfilter.sanitize sentence
      expect(sanitized).to eq expected
    end
  end

  describe 'sanitize_spaces' do
    before { Profanityfilter.load_words }

    it 'ignores spaces and filters' do
      string = 's h i t'
      replaced = Profanityfilter.sanitize_spaces string
      expect(replaced).to eq '****'
    end

    it 'ignores spaces and filters' do
      string = 'sh i t'
      replaced = Profanityfilter.sanitize_spaces string
      expect(replaced).to eq '****'
    end

    it 'ignores spaces and filters' do
      string = 's hit'
      replaced = Profanityfilter.sanitize_spaces string
      expect(replaced).to eq '****'
    end

    it 'ignores spaces and filters' do
      string = 's h i   t'
      replaced = Profanityfilter.sanitize_spaces string
      expect(replaced).to eq '****'
    end
  end

  describe 'sanitize_symbols' do
    before { Profanityfilter.load_words }

    it 'replaces a single symbol' do
      string = '$hit'
      replaced = Profanityfilter.sanitize_symbols string
      expect(replaced).to eq '****'
    end

    it 'replaces multiple symbols' do
      string = '$h!t'
      replaced = Profanityfilter.sanitize_symbols string
      expect(replaced).to eq '****'
    end

    it 'replaces numbers and symbols' do
      string = '$h1t'
      replaced = Profanityfilter.sanitize_symbols string
      expect(replaced).to eq '****'
    end

    it 'retains an ending symbol' do
      string = '$h1t!'
      replaced = Profanityfilter.sanitize_symbols string
      expect(replaced).to eq '****!'
    end

    it 'retains an ending symbol but replaces others like it' do
      string = 'sh!t!'
      replaced = Profanityfilter.sanitize_symbols string
      expect(replaced).to eq '****!'
    end

    it 'works with periods splitting a word' do
      string = 'sh.it'
      replaced = Profanityfilter.sanitize_symbols string
      expect(replaced).to eq '****'
    end
  end

  describe 'sanitize_concurrent_letters' do
    before { Profanityfilter.load_words }

    it 'handles multiple concurrent letters' do
      string = 'Foo is ssshhiit'
      replaced = Profanityfilter.sanitize_concurrent_letters string
      expect(replaced).to eq 'Foo is ****'
    end

    it 'handles words with no concurrent letters' do
      string = 'shit'
      replaced = Profanityfilter.sanitize_concurrent_letters string
      expect(replaced).to eq '****'
    end

    it 'handles words with several concurrent letters in a row' do
      string = 'shitttttttt'
      replaced = Profanityfilter.sanitize_concurrent_letters string
      expect(replaced).to eq '****'
    end

    it 'handles words with legit concurrency' do
      string = 'Concurrency'
      replaced = Profanityfilter.sanitize_concurrent_letters string
      expect(replaced).to eq 'Concurrency'
    end
  end

  describe 'add_spaces_to_word' do
    it do
      varients = Profanityfilter.add_spaces_to_word 'foo'
      expect(varients).to match_array([
        'f oo',
        'f o o',
        'fo o',
        'foo',
      ])
    end
  end
end
