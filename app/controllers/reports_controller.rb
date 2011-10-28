class ReportsController < ApplicationController

  require 'csv'
 

  def index
    #show the login page
  end
  
  def create
    #fetch and display the report
    #@harvest=Harvest.new(params[:report][:company], params[:report][:login], params[:report][:password])
    #@harvest.do_connect
    
    @connection = GLOBAL_CONNECTION


    @company = @connection.company
    Rails.logger.info "company is #{@company.inspect}"
    response = @connection.request "/clients", :get
    clients = JSON.parse(response.body)
    @retrieved_clients = []
    clients.each do |client|
      @retrieved_clients << [client["client"]["id"],client["client"]["name"]]
    end
    @invoice_details = []
    
    @retrieved_clients.each do |rc|
      response = @connection.request "/invoices?client=#{rc[0].to_s}" , :get
      invoices = JSON.parse(response.body)
      
      invoices.each do |invoice|
       due_date = invoice["doc"]["due_at"].to_date
       invoice_id = invoice["doc"]["id"]
       
       response = @connection.request "/invoices/#{invoice_id}", :get
       puts "\n\n*** full invoice: #{JSON.parse(response.body).inspect} ***\n\n"
      @full_invoice = JSON.parse(response.body)["doc"]["csv_line_items"]
     
       if 1.weeks.ago.to_date > due_date 
         @invoice_details << {:id => invoice["doc"]["id"], :client_id => invoice["doc"]["client_id"], :name => rc[1], :status => "overdue", :invoice_number => invoice["doc"]["number"], :total_amount => invoice["doc"]["due_amount"], :full_invoice =>  @full_invoice}
       else
        @invoice_details << {:id => invoice["doc"]["id"], :client_id => invoice["doc"]["client_id"],:name =>rc[1], :status => "current", :invoice_number => invoice["doc"]["number"], :total_amount => invoice["doc"]["due_amount"] , :full_invoice =>  @full_invoice}
       end
       
    
      end
    end
  end
  
  def show
    @connection = GLOBAL_CONNECTION
    @company = @connection.company

    response = @connection.request "/invoices/#{params[:id]}", :get
    @full_invoice = JSON.parse(response.body)["doc"]
    @line_items = []
    line = 0
    @full_invoice["csv_line_items"].each do |line_item|
     
      unless line == 0
      to_evaluate = line_item.split("\n")[0]
        csv_values = to_evaluate.split(",")
        @line_items << {:type => csv_values[0], :description => csv_values[1], :quantity => csv_values[2], :unit_price => csv_values[3], :amount => csv_values[4]}
      end
      line += 1
    end


    @client_id = @full_invoice["client_id"]

    response = @connection.request "/clients/#{@client_id.to_s}", :get
    @client = JSON.parse(response.body)
    
    @client_id = @full_invoice["client_id"]
     


    
  end
end
