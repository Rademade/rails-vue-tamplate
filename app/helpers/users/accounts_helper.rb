module Users::AccountsHelper
  def period_to_datetime(period)
    {
      'today' => proc { DateTime.now.beginning_of_day },
      'this week' => proc { DateTime.now.beginning_of_week },
      'this month' => proc { DateTime.now.beginning_of_month },
      'this year' => proc { DateTime.now.beginning_of_year }
    }[period.downcase].call
  end

  def get_exchange_rate(currency_from, currency_to)
    return 1.0 if currency_from == currency_to

    exchange_rates.find_by(currency_from: currency_from,
                           currency_to: currency_to).rate
  end

  def exchange_rates
    @exchange_rates = ExchangeRate.all
  end
end
