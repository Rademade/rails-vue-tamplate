class TransactionsController < ApplicationController
  before_action :authenticate_user

  def index
    transactions = account.transactions.order_by_open.page(params[:page])
    render json: {
      transactions: transactions.as_json,
      pagination_data: {
        total_pages: transactions.total_pages,
        current_page: transactions.current_page
      }
    }
  end

  private

  def account
    @account ||= Account.includes(:transactions).find_by(id: params[:account_id],
                                                         user: User.first)
  end
end
