class Api::V1::RecordsController < ApplicationController
    before_action :authenticate_user
    before_action :set_record, only: [:show, :update, :destroy]

    def index
        skip_param = params[:skip] || 0
        limit_param = params[:limit] || 100

        skip = skip_param.to_i
        limit = limit_param.to_i

        @records = Api::V1::Record.limit(limit).offset(skip)
        
        Rails.logger.debug("Getting records from database (skip #{skip}, limit #{limit})")

        render json: @records
    end

    def show
        Rails.logger.debug("Retrieve record with id #{@record.id}")

        render json: @record
    end

    def create
        @record = Api::V1::Record.new(record_params)

        if @record.save
            Rails.logger.debug("Created record with id #{@record.id}")
            render json: @record, status: :created
        else
            render json: @record.errors, status: :unprocessable_entity
        end
    end

    def update
        if @record.update(record_params)
            Rails.logger.debug("Updated record with id #{@record.id}")
            render json: @record
        else
            render json: @record.errors, status: :unprocessable_entity
        end

    end

    def destroy
        @record.destroy

        Rails.logger.debug("Deleted record with id #{@record.id}")
    end

    private

    def set_record
        @record = Api::V1::Record.find(params[:id])
    end

    def record_params
        params.require(:record).permit(:title, :img)
    end

    def authenticate_user
        # Check if the user_id session variable is present
        unless request.env['user']
            render json: {details: "User is not authenticated"}, status: :unauthorized
        end
    end
end
