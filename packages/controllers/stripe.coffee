Meteor.startup ->
  stripeKey = Meteor.settings.public.stripe.testPublishableKey
  Stripe.setPublishableKey(stripeKey)
