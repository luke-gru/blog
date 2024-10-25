# frozen_string_literal: true
ActiveAdmin.register User do
  menu priority: 40

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    actions
  end

  filter :email
  filter :first_name
  filter :last_name

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :admin
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    before_action :clean_params, only: :update

    protected

    def permitted_params
      params.permit(:utf8, :_method, :authenticity_token, :commit, :id, :locale,
        user: [
          :email, :password, :password_confirmation, :first_name, :last_name, :admin
        ]
      )
    end

    def clean_params
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
    end
  end

end
