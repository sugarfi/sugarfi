require "kemal"
require "yaml"
require "markd"

def get_posts
    posts = [] of { String, Time, String, String }
    Dir.new("blog").each do |post|
        unless post == "." || post == ".."
            file = post.split('.')[0]
            post = YAML.parse File.read("blog/#{post}")
            posts << { post["title"].as_s, Time.parse_iso8601(post["time"].as_s), Markd.to_html(post["body"].as_s), file }
        end
    end
    posts
end

get "/" do
    posts = get_posts
    posts.sort_by! { |x| x[1] }
    posts.reverse!
    render "public/index.ecr"
end

get "/blog/:post" do |env|
    posts = get_posts
    posts.reject! { |x| x[3] != env.params.url["post"] }
    if posts.size > 0
        post = posts[0]
        render "public/post.ecr"
    else
        render "public/404.ecr"
    end
end

error 404 do
    render "public/404.ecr"
end

Kemal.run