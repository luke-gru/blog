ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :first_name, :last_name, :admin

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
    def clean_params
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
    end
  end

end
