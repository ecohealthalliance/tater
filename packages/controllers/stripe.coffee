Meteor.startup ->
  stripeKey = Meteor.settings.public.stripe.publishableKey
  Stripe.setPublishableKey(stripeKey)
