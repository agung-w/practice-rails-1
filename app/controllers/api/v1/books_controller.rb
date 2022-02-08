

module Api
  module V1
    class BooksController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT=100
      before_action :authenticate_user,only: [:create,:destroy]

      def index
        books=Book.limit(limit).offset(params[:offset])#ga akan masalah kalo ga ngasih isi param soalnya kalo nill berarti kya g ada batesan gtu
        render json: BooksRepresenter.new(books).as_json
      end
      def create
        #bsa pake binding.irb buat msk ke irb pas lg jjalanin program
        author=Author.create!(author_params)
        book = Book.new(book_params.merge(author_id: author.id))
        UpdateSkuJob.perform_later(book_params[:title])

        # raise 'exit'
        if book.save
          render json: BookRepresenter.new(book).as_json,status: :created
        else
          render json: book.errors, status: :unprocessable_entity
        end
      end

      def destroy
        Book.find(params[:id]).destroy!#tanda seru ini bisa kya buat execption
        
        head :no_content
      # rescue ActiveRecord::RecordNotDestroy #kalo kya gini ada yang kurang karena ini hanya menghandle 1 error
      #   render json: {},status: :unprocessable_entity
      end
      private 

      def authenticate_user
        # binding.irb
        #authorization: bearer <token> di underskor karena kita tidak peduli
        token,_options=token_and_options(request)
        user_id=AuthenticationTokenService.decode(token)
        # raise user_id.inspect
        User.find(user_id)
      rescue ActiveRecord::RecordNotFound,JWT::DecodeError
        render status: :unauthorized 
      end
      def limit
        [params.fetch(:limit,MAX_PAGINATION_LIMIT).to_i,MAX_PAGINATION_LIMIT].min
      end
      def book_params
        params.require(:book).permit(:title)
      end
      def author_params
        params.require(:author).permit(:first_name,:last_name,:age)
      end
    end
  end
end
