require 'rails_helper'

RSpec.describe OpenaiService do
  describe '.client' do
    it 'creates a client instance with the correct configuration' do
      expect(OpenAI::Client).to receive(:new).with(
        access_token: ENV['OPENAI_API_KEY'],
        log_errors: Rails.env.development?
      ).and_call_original

      OpenaiService.client
    end

    it 'memoizes the client instance' do
      client1 = OpenaiService.client
      client2 = OpenaiService.client

      expect(client1).to eq(client2)
    end
  end

  describe '.generate_terrain_code' do
    let(:mock_response) do
      {
        'choices' => [
          { 'message' => { 'content' => "```javascript\nctx.fillStyle = '#228B22'; ctx.fillRect(0, 0, 105, 105);```" } }
        ]
      }
    end

    before do
      allow(OpenaiService).to receive(:client).and_return(double(chat: mock_response))
    end

    context 'when the request succeeds' do
      it 'returns the formatted JavaScript code' do
        result = OpenaiService.generate_terrain_code('forest')
        expect(result).to eq("ctx.fillStyle = '#228B22'; ctx.fillRect(0, 0, 105, 105);")
      end
    end

    context 'when the request fails' do
      before do
        allow(OpenaiService).to receive(:client).and_raise(StandardError, 'API error')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and returns nil' do
        result = OpenaiService.generate_terrain_code('forest')

        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/Error generating terrain code: API error/)
      end
    end
  end

  describe '.terrain_system_prompt' do
    it 'returns the correct system prompt for terrain generation' do
      prompt = OpenaiService.send(:terrain_system_prompt)
      expect(prompt).to include('You are a JavaScript canvas expert creating connected terrain patterns.')
      expect(prompt).to include('Forest: Deep green (#228B22)')
      expect(prompt).to include('CRITICAL:')
    end
  end

  describe '.terrain_user_prompt' do
    it 'generates a user prompt for the specified terrain type' do
      prompt = OpenaiService.send(:terrain_user_prompt, 'forest', {})
      expect(prompt).to include('Generate JavaScript code for a forest tile (105x105 canvas).')
      expect(prompt).to include('This forest tile must connect with adjacent forest tiles')
    end

    it 'includes context for adjacent terrains' do
      context = { north: 'water', south: 'desert' }
      prompt = OpenaiService.send(:terrain_user_prompt, 'forest', context)
      expect(prompt).to include('Adjacent terrains:')
      expect(prompt).to include('North: water')
      expect(prompt).to include('South: desert')
    end
  end
end
