class ReportsController < ApplicationController

  require 'csv'
 

  def index
    #show the login page
  end
  
  def create
    #fetch and display the report
    @harvest=Harvest.new(params[:report][:company], params[:report][:login], params[:report][:password])
    @harvest.do_connect
    @company = @harvest.company
    response = @harvest.request "/clients", :get
    
    
    
    
    
    
    
    
    
    clients = JSON.parse(response.body)
    @retrieved_clients = []
    clients.each do |client|
      @retrieved_clients << [client["client"]["id"],client["client"]["name"]]
    end
    @invoice_details = []
    
    @retrieved_clients.each do |rc|
      response = @harvest.request "/invoices?client=#{rc[0].to_s}" , :get
      invoices = JSON.parse(response.body)
      
      invoices.each do |invoice|
       due_date = invoice["doc"]["due_at"].to_date
       invoice_id = invoice["doc"]["id"]
       
       response = @harvest.request "/invoices/#{invoice_id}", :get
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
end
