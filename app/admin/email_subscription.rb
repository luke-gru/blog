# frozen_string_literal: true
ActiveAdmin.register EmailSubscription do
  index do
    selectable_column
    id_column
    column :email
    column :created_at
    column :last_subscribe_action
    column :confirmed_at
    column :unsubscribed
    column :locale
    actions
  end

  form do |f|
    f.inputs do
      f.input :email, as: :string, input_html: { readonly: true }
      f.input :locale
    end
    f.actions
  end

  action_item "Resend Confirmation Email", only: :show, if: proc { not resource.confirmed? } do
    link_to 'Resend Confirm Email', resend_confirmation_email_admin_email_subscription_path(resource), data: { confirm: "Are you sure?", method: "post" }
  end

  # @params :id
  member_action :resend_confirmation_email, method: :post do
    sub = EmailSubscription.find_by_id(params[:id])
    unless sub
      flash[:error] = "Could not find subscription with id: #{params[:id]}"
      redirect_to(admin_email_subscriptions_path) and return
    end
    result = sub.resend_confirmation_email!(inline: true)
    if result[:success]
      flash[:notice] = "Successfully resent confirmation email"
    else
      flash[:error] = "Error resending confirmation email: #{result[:error]}"
    end
    redirect_to(admin_email_subscription_path(sub))
  end

  controller do
    def permitted_params
      params.permit(:utf8, :_method, :authenticity_token, :commit, :id, :locale,
        email_subscription: [
          :email, :locale,
        ]
      )
    end
  end
end