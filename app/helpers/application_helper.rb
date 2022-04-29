module ApplicationHelper
  def image_show(model: nil, attribute: nil, file: nil, height: 150)
    if file&.url.present?
      image_tag file.url, style: "height:#{height}px;width:auto;"
      return
    end
    return unless model&.send(attribute).url.present?
    image_tag model.send(attribute).url, style: "height:#{height}px;width:auto;"
  end

  def show_slider(model, attribute: :files, height: 120)
    return unless model.send(attribute).present?
    html = Arbre::Context.new do
      div class: 'slider' do
        model.send(attribute).each do |file|
          img src: file.url, style: "height:#{height}px;width:auto;"
        end
        div class: 'previewer'
      end
    end
    raw html
  rescue
    nil
  end
end
