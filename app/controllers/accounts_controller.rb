class AccountsController < ApplicationController
  include Users::AccountsHelper
  before_action :authenticate_user
  before_action :set_from_to_date, only: [:profitability, :monthly_gain]
  before_action :set_accounts, only: [:income, :profitability, :monthly_gain]

  def index
    data = current_user.accounts.map do |account|
      exchange_rate = get_exchange_rate(account.currency, current_currency)
      profit = account.total_profit
      deposits = account.total_deposits

      account.as_json.merge(
        gain: Account.calculate_gain(profit, deposits),
        balance: (account.latest_balance * exchange_rate).round(2),
        profit: (profit * exchange_rate).round(2),
        interest: (account.total_interest * exchange_rate).round(2),
        deposits: (deposits * exchange_rate).round(2),
        withdrawals: (account.total_withdrawals * exchange_rate).round(2)
      )
    end
    render json: data
  end

  def income
    date = period_to_datetime(params[:period])

    balance = 0.0
    profit = 0.0
    @accounts.each do |account|
      exchange_rate = get_exchange_rate(account.currency, current_currency)
      balance += account.balance_before(date) * exchange_rate
      profit += ProfitByPeriod.call(Transaction.where(account_id: account.id), from_date: date) * exchange_rate
    end

    render json: {
      period: params[:period],
      gain: Account.calculate_gain(profit, balance).round(2),
      profit: profit.round(2)
    }
  end

  def profitability
    @profits = {}

    @accounts.each do |account|
      profit = ProfitByPeriod.call(Transaction.where(account_id: account.id).group_by_day(:close_time),
                                   from_date: @from_date, to_date: @to_date)
      exchange_rate = get_exchange_rate(account.currency, current_currency)
      initial_profit = account.profit_before(@from_date) * exchange_rate

      profit.each do |k, v|
        initial_profit += v * exchange_rate
        if @profits[k]
          @profits[k] += initial_profit
        else
          @profits[k] = initial_profit
        end
      end
    end

    render json: @profits.map { |k, v| { x: k, y: v.round(2) } }
  end

  def monthly_gain
    @from_date = @from_date.beginning_of_month
    @monthly_data_for_gain = {}

    @accounts.each do |account|
      profit = ProfitByPeriod.call(Transaction.where(account_id: account.id).group_by_month(:close_time),
                                   from_date: @from_date, to_date: @to_date)
      exchange_rate = get_exchange_rate(account.currency, current_currency)
      initial_balance = account.balance_before(@from_date)

      profit.each do |k, v|
        balance_change = profit[k - 1.month]
        initial_balance += balance_change if balance_change
        if @monthly_data_for_gain[k]
          @monthly_data_for_gain[k].merge!(
            profit: v * exchange_rate,
            balance: initial_balance * exchange_rate
          ) { |_, a_v, b_v| a_v + b_v }
        else
          @monthly_data_for_gain[k] = { profit: v * exchange_rate, balance: initial_balance * exchange_rate }
        end
      end
    end

    gain = @monthly_data_for_gain.map do |month, data|
      {
        x: month,
        y: Account.calculate_gain(data[:profit], data[:balance]).round(2)
      }
    end

    render json: gain
  end

  private

  def set_from_to_date
    @from_date = params[:from].to_datetime
    @to_date = params[:to].to_datetime
  end

  def set_accounts
    @accounts = if params[:account_id]
                  current_user.accounts.where(id: params[:account_id])
                else
                  current_user.accounts
                end
  end

  def current_currency
    @current_currency ||= params[:currency] ? params[:currency].upcase : 'USD'
  end
end
