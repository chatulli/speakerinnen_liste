class ProfilesController < ApplicationController
  include ProfilesHelper
  include CategoriesHelper
  include ActsAsTaggableOn::TagsHelper


  before_filter :require_permission, only: [:edit, :destroy, :update]

  def index
    if params[:topic]
      @profiles = profiles_for_scope(params[:topic])
    else
      @profiles = profiles_for_index
    end
    @tags = ActsAsTaggableOn::Tag.most_used(100)
  end

  def category
    @category = Category.find(params[:category_id])
    @tags     = @category.tags
    if @tags.any?
      @tag_names = @tags.pluck(:name)
      @profiles = profiles_for_scope(@tag_names)
      @published_tags = @profiles.map { |p| p.topics.pluck(:name) }.flatten.uniq
      @tags = @tags.select { |t| @published_tags.include?(t.to_s) }
    else
      @profiles = profiles_for_index
      redirect_to profiles_url, notice: ("No Tag for that Category found!")
    end
  end

  def show
    @profile = Profile.find(params[:id])

    if @profile.published? or can_edit_profile?(current_profile, @profile)
      @message = Message.new
      @medialinks = @profile.medialinks.order(:position)
    else
      redirect_to profiles_url, notice: (I18n.t("flash.profiles.show_no_permission"))
    end

  end

  # action, view, routes should be deleted
  def new
    @profile = Profile.new
  end

  # should reuse the devise view
  def edit
    @profile = Profile.find(params[:id])
    build_missing_translations(@profile)
  end

  def update
    @profile = Profile.find(params[:id])
    medialinks = params[:medialinks] || []
    all_medialinks_saved_successfully = true
    medialinks.each_with_index do |medialink, position|
      medialink[:position] = position
      if medialink[:id]
        unless Medialink.find(medialink[:id]).update_attributes(medialink)
          all_medialinks_saved_successfully = false
        end
      else
        unless @profile.medialinks.build(medialink).save
          all_medialinks_saved_successfully = false
        end
      end
    end

    @profile.linguistic_abilities.clear
    if params[:other_languages]
      params[:other_languages].each do |name| 
        if name.present?
          language = Language.find_or_create_by_name(name)
          @profile.linguistic_abilities.create language_id: language.id
        end
      end
    end
    if @profile.update_attributes(params[:profile]) && all_medialinks_saved_successfully
      redirect_to @profile, notice: (I18n.t("flash.profiles.updated"))
    else current_profile
      #build_missing_translations(@profile)
      #redirect_to edit_profile_path(@profile), alert: (I18n.t("flash.profiles.failed"))
      render action: "edit", alert: (I18n.t("flash.profiles.failed"))
    end
  end

  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy
    redirect_to profiles_url, notice: (I18n.t("flash.profiles.destroyed"))
  end

  def require_permission
    profile = Profile.find(params[:id])
    unless can_edit_profile?(current_profile, profile)
      redirect_to profiles_url, notice: (I18n.t("flash.profiles.no_permission"))
    end
  end

  private

  def build_missing_translations(object)
    I18n.available_locales.each do |locale|
      unless object.translated_locales.include?(locale)
        object.translations.build(locale: locale)
      end
    end
  end

  def profiles_for_index
    Profile.is_published.order("created_at DESC").page(params[:page]).per(24)
  end

  def profiles_for_scope(tag_names)
    Profile.is_published
            .tagged_with(tag_names, any: true)
            .order("created_at DESC")
            .page(params[:page])
            .per(24)
  end

end
