require 'active_support/all'
require 'open-uri'

class Api::V1::WeixinController < Api::V1Controller
  respond_to :json

  def weixin_access_verify
    echostr = params['echostr']
    # if verification and echostr != nil
    #     echostr
    # else
    #   eachostr = 'access verification fail'
    # end
    respond_with eachostr
  end

  def verification
    signature = params[:signature] || 'signature'
    timestamp = params[:timestamp] || 'timestamp'
    nonce = params[:nonce] || 'nonce'

    token = 'australian1984'  # keep it as the same as it on wechat mp
    tmplist = [token, timestamp, nonce]
    tmplist.sort!
    tmpstr = tmplist.join
    hashstr = Digest::SHA1.hexdigest(tmpstr)

    hashstr == signature
  end


  #transfer the msg to dict
  def parse_msg(rawmsgstr)
      Hash.from_xml(rawmsgstr)
  end


  def is_text_msg(msg)
      msg['MsgType'] == 'text'
  end


  def is_location_msg(msg)
      msg['MsgType'] == 'location'
  end


  def user_subscribe_event(msg)
      msg['MsgType'] == 'event' and msg['Event'] == 'subscribe'
  end

  HELP_INFO = %{
  欢迎关注澳洲一刻^_^

  我们为您奉上最新鲜的澳洲生活资讯，最前沿的移民信息。
  ❤回复'm'或者'money' 获取最新澳币汇率 (新版)
  ❤回复'p'或者'petrol' 获取澳洲最新油价周期 (新)
  ❤澳洲一刻社区42bang.com已准备就绪,欢迎访问!
  }


  def help_info(msg)
      response_text_msg(msg, HELP_INFO)
  end


  def getAUDCNY()
      api = 'http://download.finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=AUDCNY=x'
      content = nil
      begin
        open(api){ |io|
          content = io.read.split
        }
      rescue
          puts "Error:getAUDCNY()"
      end
      content
  end


  def currency_info_AUDCNY(msg)
      cur = getAUDCNY()
      if cur != nil
        response_text_msg(msg, %{Hi, 澳洲一刻的小伙伴：
  当前 1 澳币可以兑换  #{cur[1]} 人民币} )
      else
        response_text_msg(msg, HELP_INFO)
      end
  end
  
  class Cur
  end  

  def currency_info_AUDCNY_Pic(msg)
      cur = getAUDCNY()
      if cur != None
          
          cur_obj = Cur.new
          cur_obj.title = %{当前 1 澳币可兑换  #{cur[1]} 人民币}
          cur_obj.shorten_content = %{点击查看最近半小时和24小时汇率趋势图^_^. 
  也可以直接登录澳洲一刻小伙伴们的社区
  [ http://42bang.com ] 随时查看汇率哦！
  社区里还有很多关于澳洲的精彩文章，都很值得收藏！欢迎小伙伴们投稿:)}

          cur_obj.imgthumbnail = "http://42bang.com/static/public/img/cur1.thumbnail.jpg"
          cur_obj.url = "http://42bang.com/cur/all"
          curs = []
          curs << cur_obj
          response_news_msg(msg, curs)
      else
          response_text_msg(msg, HELP_INFO)
      end
  end
      
  class Petrol
  end   

  def petrol(msg)
      p_obj = Petrol.new
      p_obj.title = %{最新的澳洲油价变化周期}
      p_obj.shorten_content = %{想知道哪天去加油最划算吗？点击查看最近油价的最低点和各大城市的最新油价周期情况。^_^. 
  也可以直接登录澳洲一刻小伙伴们的社区
  [ http://42bang.com ] 随时查看哦！
  社区里还有很多关于澳洲的精彩文章，都很值得收藏！欢迎小伙伴们投稿:)}
      p_obj.imgthumbnail = "http://42bang.com/static/public/img/p.thumbnail.jpg"
      p_obj.url = 'http://42bang.com/petrol'
      pets = []
      pets << p_obj
      response_news_msg(msg, pets)
  end

      
      
   
  NEWS_MSG_HEADER_TPL= %{
  <xml>
  <ToUserName><![CDATA[%s]]></ToUserName>
  <FromUserName><![CDATA[%s]]></FromUserName>
  <CreateTime>%s</CreateTime>
  <MsgType><![CDATA[news]]></MsgType>
  <ArticleCount>%d</ArticleCount>
  <Articles>
  }
  #<Content><![CDATA[]]></Content>

  NEWS_MSG_TAIL = %{
  </Articles>
  </xml>
  }
  #<FuncFlag>1</FuncFlag>


  #msg reply, news with pictures
  def response_news_msg(recvmsg, posts)
      msgHeader = NEWS_MSG_HEADER_TPL % [recvmsg['FromUserName'], recvmsg['ToUserName'],
          Time.now.to_i.to_s, posts.size]
      msg = ''
      msg += msgHeader
      msg += make_articles(posts)
      msg += NEWS_MSG_TAIL
  end


  def make_articles(posts)
      msg = ''
      if posts.size == 1
          msg += make_single_item(posts[0])
      end

      msg
  end

  NEWS_MSG_ITEM_TPL = %{
  <item>
      <Title><![CDATA[%s]]></Title>
      <Description><![CDATA[%s]]></Description>
      <PicUrl><![CDATA[%s]]></PicUrl>
      <Url><![CDATA[%s]]></Url>
  </item>
   }


  #if msg with pic only has one, show more desc
  def make_single_item(message)
      #filter the sensitive words
      title_r = message.title
      description_r = message.shorten_content
      title = '%s' % title_r
      description = '%s' % description_r
      picUrl = message.imgthumbnail
      
      item = NEWS_MSG_ITEM_TPL % [title, description, picUrl, message.url]
      #item = NEWS_MSG_ITEM_TPL
  end

  TEXT_MSG_TPL = %{
  # <xml>
  # <ToUserName><![CDATA[%s]]></ToUserName>
  # <FromUserName><![CDATA[%s]]></FromUserName>
  # <CreateTime>%s</CreateTime>
  # <MsgType><![CDATA[text]]></MsgType>
  # <Content><![CDATA[%s]]></Content>
  # <FuncFlag>0</FuncFlag>
  </xml>
  }


  def response_text_msg(msg, content)
      s = TEXT_MSG_TPL % [msg['FromUserName'], msg['ToUserName'],
          Time.now.to_i.to_s, content]
  end

end
