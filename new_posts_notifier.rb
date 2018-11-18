require 'net/smtp'

# NewPostsNotifier
class NewPostsNotifier
  def notify(posts)
    return if posts.empty?

    email_subject = build_email_subject(posts)
    email_content = build_email_content(posts)
    email_addr = ENV['EJMR_CHECKER_NOTIFICATION_EMAIL']
    send_email(email_addr, email_subject, email_content)
  end

  private

  # rubocop:disable Metrics/MethodLength
  def send_email(email_addr, subject, content)
    Aws::SES::Client.new.send_email(
      source: "emjr-checker <#{email_addr}>",
      destination: {
        to_addresses: Array(email_addr)
      },
      message: {
        subject: {
          data: subject,
          charset: 'utf-8'
        },
        body: {
          html: {
            data: content,
            charset: 'utf-8'
          }
        }
      }
    )
  end
  # rubocop:enable Metrics/MethodLength

  def build_email_subject(posts)
    "[ejmr-checker]#{posts.size} new posts found - " \
    "#{Time.now.strftime('%Y/%m/%d %H:%M:%S')}"
  end

  POST_STYLE = 'border-top: 1px solid black'.freeze
  def build_email_content(posts)
    posts
      .map { |p| "<div style='#{POST_STYLE}'>#{p[:content]}</div>" }
      .join
  end
end
