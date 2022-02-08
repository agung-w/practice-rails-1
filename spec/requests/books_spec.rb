require 'rails_helper'

describe 'Books API',type: :request do
    let(:first_author) { FactoryBot.create(:author,first_name:'George',last_name:'The Jungler',age:80) }
    let(:second_author) { FactoryBot.create(:author,first_name:'Kenny',last_name:'Sudarman',age:78) }
    describe 'GET /books' do
        before do
            FactoryBot.create(:book, title:'1984',author:first_author)
            FactoryBot.create(:book, title:'360 No Scope',author:second_author)
        end
        it 'returns all books' do
            
            get '/api/v1/books'
            
            expect(response).to have_http_status(:success)
            expect(JSON.parse(response.body).size).to eq(2)
            expect(response_body).to eq(
                [
                    {
                        'id'=>1,
                        'title'=>'1984',
                        'author_name'=>'George The Jungler',
                        'author_age'=>80
                    },
                    {
                        'id'=>2,
                        'title'=>'360 No Scope',
                        'author_name'=>'Kenny Sudarman',
                        'author_age'=>78
                    }
                ]
            )
        end
        it 'returns a subset of books based on limit' do
            get '/api/v1/books',params: {limit:1}
            
            expect(response).to have_http_status(:success)
            expect(JSON.parse(response.body).size).to eq(1)
            expect(response_body).to eq(
                [{
                    'id'=>1,
                    'title'=>'1984',
                    'author_name'=>'George The Jungler',
                    'author_age'=>80
                }]
            )
        end
        it 'returns a subset of books based on limit and offset' do
            get '/api/v1/books',params: {limit:1,offset:1}
            
            expect(response).to have_http_status(:success)
            expect(JSON.parse(response.body).size).to eq(1)
            expect(response_body).to eq(
                [{
                    'id'=>2,
                    'title'=>'360 No Scope',
                    'author_name'=>'Kenny Sudarman',
                    'author_age'=>78
                }]
            )
        end
        
    end
    describe 'POST /books' do
        let!(:user){FactoryBot.create(:user,password: 'psword')}
        it 'create a new book' do
            expect{
                post '/api/v1/books',params:{
                    book: {title:'The martian'},
                    author:{first_name:'Andy',last_name:'Weir',age:'48'}
                },headers:{"Authorization"=>"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg"}
            }.to change {Book.count}.from(0).to(1)
            expect(response).to have_http_status(:created)
            expect(Author.count).to eq(1)
            expect(response_body).to eq(
                {
                    'id'=>1,
                    'title'=>'The martian',
                    'author_name'=>'Andy Weir',
                    'author_age'=>48
                }
            )
        end
        
    end
    describe 'DELETE /books/:id' do
        let!(:book){FactoryBot.create(:book, title:'1984',author:first_author)} #kaya cara lain deklarasi
        let!(:user){FactoryBot.create(:user,password: 'psword')}
        
        #tanda seru dipake biar pas di jalanin tes dijalanin si let juga langsung di jalanin ga nunggu dipanggil di dalem#{}
        it 'delete a book' do
            expect{  
                delete "/api/v1/books/#{book.id}",
                headers:{"Authorization"=>"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSJ9.M1vu6qDej7HzuSxcfbE6KAMekNUXB3EWtxwS0pg4UGg"}
            }.to change{Book.count}.from(1).to(0)
            
            expect(response).to have_http_status(:no_content)
        end
    end
end