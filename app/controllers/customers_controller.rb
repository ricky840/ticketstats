class CustomersController < ApplicationController
  def index
    @customer = Customer.all
  end

  def show
    @customer = Customer.find(params[:id])
    @requestor = Requestor.new
    @requestors = @customer.requestors
    hsh_created = Hash.new
    hsh_created_by_requestor = Hash.new
    lst_rtuser_ids = Array.new

    @requestors.each do |requestor|
      lst_rtuser_ids.append(requestor.rtuser_id)
      hsh_created_by_requestor[requestor.email] = Rtticket.total_number_of_created_tickets(requestor.rtuser_id)
      created_tickets = Rtticket.tickets_created_by_user(requestor.rtuser_id)
      created_tickets.each do |date, count|
        hsh_created[date] = hsh_created[date].to_i + count
      end
    end
    @open_tickets = Rtticket.open_tickets(lst_rtuser_ids)
    @all_created = Rtticket.total_number_of_created_tickets(lst_rtuser_ids)
    @chart_created = line_chart(hsh_created, "Tickets created by customer", "blue", "Tickets")
    @chart_created_by_requestor = bar_chart(hsh_created_by_requestor, "Tickets created by requestor", "green", "Tickets")
  end

  def create
    @customer = Customer.new(params[:customer])
    @requestor = @customer.requestors.new(email: params[:email])
    @customer.valid?
    if @requestor.valid?
      if @customer.save
        @requestor.customer_id = @customer.id
        @requestor.rtuser_id = Requestor.get_rtuser_id(params[:email])
        @requestor.save
        redirect_to customers_path
      else
        render action: "new"
      end
    else
      render action: "new"
    end
  end

  def new
    @requestor = Requestor.new
    @customer = Customer.new
  end

  def destroy
    customer = Customer.find(params[:id])
    if customer.destroy
      redirect_to customers_path, notice: "Deleted Successfully"
    else
      redirect_to customer_path(id: customer.id), alert: "Error!"
    end
  end
end
