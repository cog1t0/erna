class Api::V1::WebhookController < ApplicationController
    require 'line/bot'
    protect_from_forgery :except => [:webhook]
    
    def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end

    def webhook
        logger.debug("===== start webhook")
        body = request.body.read

        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
            head :bad_request
        end

        events = client.parse_events_from(body)

        events.each { |event|
            case event
            when Line::Bot::Event::Message
                logger.debug("===== start Message")
                case event.type
                when Line::Bot::Event::MessageType::Text
                    logger.debug("===== start Message Text")
                    message = {
                        type: 'text',
                        text: event.message['text']
                    }
                    client.reply_message(event['replyToken'], message)
                when Line::Bot::Event::MessageType::Location
                    logger.debug("===== start Message Location")
                    lat = event.message['latitude']
                    lng = event.message['longitude']
                    name = event.message['title']
                    user_id = event['source']['userId']
                    map = Map.new(user_id: user_id, lat: lat, lng: lng, name: name)
                    if map.save!
                        message = {
                            type: 'text',
                            text: "位置情報を登録しました https://erna-map.herokuapp.com/maps/#{map.id}"
                        }
                        client.reply_message(event['replyToken'], message)
                    else
                        message = {
                            type: 'text',
                            text: "エラーが発生しました"
                        }
                        client.reply_message(event['replyToken'], message)
                    end
                end
            end
        }

        head :ok
    end

    def add_map
        logger.debug('======================= add_map start')
        lat = params['latitude']
        lng = params['longitude']
        name = params['title']
        user_id = params['user_id']
        map = Map.new(user_id: user_id, lat: lat, lng: lng, name: name)
        logger.debug("======================= add_map map #{map.inspect}")

        if map.save!
            message = "位置情報を登録しました https://erna-map.herokuapp.com/maps/#{map.id}"
        else
            message = "エラーが発生しました"
        end
        json = {"message": message}
        logger.debug("======================= add_map json #{json}")
        render :json => json
    end
end
# [ { type: 'message',
#     replyToken: '0db7ab4592bc4b32bf92cb8b705a486c',
#     source:
#      { userId: 'Ubc6ad91e177933c80cf44e01ded185b4', type: 'user' },
#     timestamp: 1562536767965,
#     message:
#      { type: 'location',
#        id: '10173951618888',
#        title: '東川口駅',
#        address: '戸塚1/東川口1 川口市, 埼玉県 日本',
#        latitude: 35.87532421233835,
#        longitude: 139.74461317062378 } } ]
# message
