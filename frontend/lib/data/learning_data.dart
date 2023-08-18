final List<Map<String, dynamic>> learningData = [
  {
    "topicName": "Cash-Secured Basics",
    "slides": [
      {
        "headline": "What is it?",
        "graphic": null,
        "information":
            "A cash-secured put is an options strategy where an investor sells a put option and simultaneously holds a reserved cash amount, equivalent to purchasing the stock. It's a method to generate income or potentially acquire stocks at a lower cost."
      },
      {
        "headline": "Mechanism",
        "graphic": null,
        "information":
            "When selling the put, the investor receives a premium. If the stock's price falls below the strike price at expiration, the investor may need to buy the stock using the reserved cash. If not, they simply pocket the premium."
      },
      {
        "headline": "Benefits",
        "graphic": null,
        "information":
            "Using cash-secured puts can lead to consistent income through premiums, especially in flat markets. Additionally, it's a strategic way to purchase desired stocks at a discount."
      }
    ]
  },
  {
    "topicName": "Risk vs. Reward",
    "slides": [
      {
        "headline": "Potential Profits",
        "graphic": null,
        "information":
            "The immediate profit from this strategy is the premium received when the put is sold. This amount is yours to keep, regardless of the stock's movement."
      },
      {
        "headline": "Potential Losses",
        "graphic": null,
        "information":
            "Risks emerge when the stock price drops considerably. Your loss equals the difference between the strike price (minus the premium) and the stock's current price. This can escalate if the stock plummets."
      },
      {
        "headline": "Break-Even Analysis",
        "graphic": null,
        "information":
            "Your break-even point is the strike price minus the premium. This means if the stock price is above this value at expiration, you'll register a net profit."
      }
    ]
  },
  {
    "topicName": "Stocks & Strikes",
    "slides": [
      {
        "headline": "Evaluating Stocks",
        "graphic": null,
        "information":
            "Choosing the right stock is pivotal. Analyze company fundamentals, study technical charts for trends, and stay updated on macroeconomic factors affecting the stock."
      },
      {
        "headline": "Picking Strikes",
        "graphic": null,
        "information":
            "Selecting the strike price depends on risk tolerance. A lower strike means lower risk but a smaller premium. Conversely, a higher strike offers more premium but greater risk of assignment."
      },
      {
        "headline": "Maturity Matters",
        "graphic": null,
        "information":
            "The expiration date is crucial. Short-term options may have rapid time decay, benefiting sellers, but they require frequent management. Long-term options offer larger premiums but pose greater assignment risk."
      }
    ]
  },
  {
    "topicName": "Advanced Strategies",
    "slides": [
      {
        "headline": "Volatility Impacts",
        "graphic": null,
        "information":
            "Volatility affects premium amounts. High implied volatility (IV) means higher premiums, benefiting sellers. However, it also implies greater price uncertainty for the underlying stock."
      },
      {
        "headline": "Navigating Assignment",
        "graphic": null,
        "information":
            "If the option is in-the-money at expiration, it may be exercised, leading to stock assignment. It's important to have strategies, such as rolling the option, to manage potential assignments."
      },
      {
        "headline": "Position Management",
        "graphic": null,
        "information":
            "If a position moves against you, consider rolling the option to a different expiration or strike. This can extend the trade and potentially reduce losses."
      }
    ]
  }
];
