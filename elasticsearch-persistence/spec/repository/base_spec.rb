require 'spec_helper'

describe Elasticsearch::Persistence::Repository do

  before do
    class MyRepository; include Elasticsearch::Persistence::Repository; end
  end

  after do
    begin; MyRepository.delete_index!; rescue; end
    Object.send(:remove_const, MyRepository.name) if defined?(MyRepository)
  end

  shared_examples 'a base repository' do

    describe '#client' do

      context 'when client is not passed as an argument' do

        it 'returns the default client' do
          expect(repository.client).to be_a(Elasticsearch::Transport::Client)
        end

        context 'when the method is called more than once' do

          it 'returns the same client' do
            expect(repository.client).to be(repository.client)
          end
        end
      end

      context 'when a client is passed as an argument' do

        let(:new_client) do
          Elasticsearch::Transport::Client.new
        end

        before do
          repository.client(new_client)
        end

        it 'sets the client' do
          expect(repository.client).to be(new_client)
        end

        context 'when the method is called more than once' do

          it 'returns the same client' do
            repository.client
            expect(repository.client).to be(new_client)
          end
        end

        context 'when the client is nil' do

          before do
            repository.client(nil)
          end

          it 'does not set the client to nil' do
            expect(repository.client).to be_a(Elasticsearch::Transport::Client)
          end
        end
      end
    end

    describe '#client=' do

      let(:new_client) do
        Elasticsearch::Transport::Client.new
      end

      before do
        repository.client = new_client
      end

      it 'sets the new client' do
        expect(repository.client).to be(new_client)
      end

      context 'when the client is set to nil' do

        before do
          repository.client = nil
        end

        it 'falls back to a default client' do
          expect(repository.client).to be_a(Elasticsearch::Transport::Client)
        end
      end
    end

    describe '#index_name' do

      context 'when name is not passed as an argument' do

        it 'returns the default index name' do
          expect(repository.index_name).to eq('repository')
        end

        context 'when the method is called more than once' do

          it 'returns the same index name' do
            expect(repository.index_name).to be(repository.index_name)
          end
        end
      end

      context 'when a name is passed as an argument' do

        let(:new_name) do
          'my_other_repository'
        end

        before do
          repository.index_name(new_name)
        end

        it 'sets the index name' do
          expect(repository.index_name).to eq(new_name)
        end

        context 'when the method is called more than once' do

          it 'returns the same name' do
            repository.index_name
            expect(repository.index_name).to eq(new_name)
          end
        end

        context 'when the name is nil' do

          before do
            repository.index_name(nil)
          end

          it 'does not set the name to nil' do
            expect(repository.index_name).to eq(new_name)
          end
        end
      end
    end

    describe '#index_name=' do

      let(:new_name) do
        'my_other_repository'
      end

      before do
        repository.index_name = new_name
      end

      it 'sets the index name' do
        expect(repository.index_name).to eq(new_name)
      end

      context 'when the name is set to nil' do

        before do
          repository.index_name = nil
        end

        it 'falls back to the default repository name' do
          expect(repository.index_name).to eq('repository')
        end
      end
    end

    describe '#document_type' do

      context 'when type is not passed as an argument' do

        it 'returns the default document type' do
          expect(repository.document_type).to eq('_doc')
        end

        context 'when the method is called more than once' do

          it 'returns the same type' do
            expect(repository.document_type).to be(repository.document_type)
          end
        end
      end

      context 'when a type is passed as an argument' do

        let(:new_type) do
          'other_document_type'
        end

        before do
          repository.document_type(new_type)
        end

        it 'sets the type' do
          expect(repository.document_type).to be(new_type)
        end

        context 'when the method is called more than once' do

          it 'returns the same type' do
            repository.document_type
            expect(repository.document_type).to be(new_type)
          end
        end

        context 'when the type is nil' do

          before do
            repository.document_type(nil)
          end

          it 'does not set the document_type to nil' do
            expect(repository.document_type).to eq(new_type)
          end
        end
      end
    end

    describe '#document_type=' do

      let(:new_type) do
        'other_document_type'
      end

      before do
        repository.document_type = new_type
      end

      it 'sets the new type' do
        expect(repository.document_type).to be(new_type)
      end

      context 'when the document type is set to nil' do

        before do
          repository.document_type = nil
        end

        it 'falls back to a default document type' do
          expect(repository.document_type).to eq('_doc')
        end
      end
    end

    describe '#klass' do

      context 'when class is not passed as an argument' do

        it 'returns nil' do
          expect(repository.klass).to be_nil
        end
      end

      context 'when a class is passed as an argument' do

        let(:new_class) do
          Hash
        end

        before do
          repository.klass(new_class)
        end

        it 'sets the class' do
          expect(repository.klass).to be(new_class)
        end

        context 'when the method is called more than once' do

          it 'returns the same type' do
            repository.klass
            expect(repository.klass).to be(new_class)
          end
        end

        context 'when the class is nil' do

          before do
            repository.klass(nil)
          end

          it 'does not set the class to nil' do
            expect(repository.klass).to eq(new_class)
          end
        end
      end
    end

    describe '#klass=' do

      let(:new_class) do
        Hash
      end

      before do
        repository.klass = new_class
      end

      it 'sets the new class' do
        expect(repository.klass).to be(new_class)
      end

      context 'when the class is set to nil' do

        before do
          repository.klass = nil
        end

        it 'sets the class to nil' do
          expect(repository.klass).to be_nil
        end
      end
    end
  end

  describe 'an enforced singleton' do

    describe '#client' do

      context 'when the client is changed on the class' do

        let(:new_client) do
          Elasticsearch::Transport::Client.new
        end

        before do
          MyRepository.client(new_client)
        end

        it 'applies to the singleton instance as well' do
          expect(MyRepository.instance.client).to be(new_client)
        end
      end
    end

    describe '#index_name' do

      context 'when the index name is changed on the class' do

        let!(:new_name) do
          'my_other_repository'
        end

        before do
          MyRepository.index_name(new_name)
        end

        it 'applies to the singleton instance as well' do
          expect(MyRepository.instance.index_name).to be(new_name)
        end
      end
    end

    describe '#document_type' do

      context 'when the document type is changed on the class' do

        let!(:new_type) do
          'my_other_document_type'
        end

        before do
          MyRepository.document_type(new_type)
        end

        it 'applies to the singleton instance as well' do
          expect(MyRepository.instance.document_type).to be(new_type)
        end
      end
    end

    describe '#klass' do

      context 'when the klass is changed on the class' do

        let(:new_class) do
          Hash
        end

        before do
          MyRepository.klass = new_class
        end

        it 'applies to the singleton instance as well' do
          expect(MyRepository.instance.klass).to be(new_class)
        end
      end
    end

    context 'when an instance is attempted to be created' do

      it 'raises an error' do
        expect {
          MyRepository.new
        }.to raise_exception(NoMethodError)
      end
    end

    context 'when custom methods are defined' do

      before do
        class MyRepository
          include Elasticsearch::Persistence::Repository

          def routing_value
            1
          end
        end
      end

      it 'allows the method to be called on the instance as well' do
        expect(MyRepository.routing_value).to eq(1)
        expect(MyRepository.instance.routing_value).to eq(1)
      end
    end
  end

  context 'when methods are called on the class' do

    let(:repository) do
      MyRepository
    end

    it_behaves_like 'a base repository'
  end

  context 'when methods are called on the class instance' do

    let(:repository) do
      MyRepository.instance
    end

    it_behaves_like 'a base repository'
  end
end
