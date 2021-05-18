describe "POST /signup" do
    context "novo usuario" do
        before(:all) do
            payload = { name: "Pitty", email: "pitty@bol.com.br", password: "pwd123" }
            MongoDB.new.remove_user(payload[:email])

            @result = Signup.new.create(payload)
        end

        it "valida status code" do
            expect(@result.code).to eql 200
        end

        it "valida id do usuario" do 
            expect(@result.parsed_response["_id"].length).to eql 24
        end
    end

    context "usuario ja existe" do
        before(:all) do
            # dado que eu tenho um novo usuario
            payload = { name: "Joao da Silva", email: "joao@bol.com.br", password: "pwd123" }
            MongoDB.new.remove_user(payload[:email])
            
            # e o email desse usuario ja foi cadastrado no sistema
            Signup.new.create(payload)

            # quando faco uma requisicao para a rota /signup 
            @result = Signup.new.create(payload)
        end

        it "deve retornar 409" do
            # entao deve retornar 409
            expect(@result.code).to eql 409
        end

        it "valida mensagem de resposta" do 
            expect(@result.parsed_response["error"]).to eql "Email already exists :("
        end

    end

    examples = [
        {
            title: "nome em branco",
            payload: { name: "", email: "joao@bol.com.br", password: "pwd123" },
            code: 412,                puts @result.code
            puts @result.parsed_response["error"]
        {
            title: "sem campo nome",
            payload: { email: "joao@bol.com.br", password: "pwd123" },
            code: 412,
            error: "required name"

        },
        {
            title: "email em branco",
            payload: { name: "Joao da Silva", email: "", password: "pwd123" },
            code: 412,
            error: "required email"

        },
        {
            title: "sem campo email",
            payload: { name: "Joao da Silva", password: "pwd123" },
            code: 412,
            error: "required email"

        },
        {
            title: "senha em branco",
            payload: { name: "Joao da Silva", email: "joao@bol.com.br", password: "" },
            code: 412,
            error: "required password"

        },
        {
            title: "senha campo senha",
            payload: { name: "Joao da Silva", email: "joao@bol.com.br" },
            code: 412,
            error: "required password"

        },
    ]

    examples.each do |e|
        context "#{e[:title]}" do
            before(:all) do
                @result = Signup.new.create(e[:payload])
                
            end
    
            it "valida status code #{e[:code]}" do
                expect(@result.code).to eql e[:code]
            end
    
            it "valida mensagem de resposta" do
                expect(@result.parsed_response["error"]).to eql e[:error]
            end
        end
    end
end