# frozen_string_literal: true
ActiveAdmin.register SubscriptionEmailSent do
  menu priority: 25, label: "Emails Sent"
  actions :all, except: [:new, :create, :update, :edit, :destroy]
end
