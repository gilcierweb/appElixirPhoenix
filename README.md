# AppElixirPhoenix

Iniciando estudos com Elixir e Phoenix Framework

Autor: GilcierWeb gilcierweb@gmail.com.

Website: http://gilcierweb.com.br.

Licença: http://www.opensource.org/licenses/mit-license.php The MIT License.

```shell
cd AppElixirPhoenix/

mix ecto.create

mix ecto.migrate

mix phoenix.gen.html Post posts title body:text

# add web/router.ex
scope "/", AppElixirPhoenix do
  ...  
  resources "/posts", PostController
end

mix ecto.migrate

mix phoenix.gen.model Comment comments name:string content:text post_id:references:posts

mix ecto.migrate

mix ecto.rollback

#add web/models/comment.ex
belongs_to :post, AppElixirPhoenix.Post, foreign_key: :post_id

#add web/models/post.ex
has_many :comments, AppElixirPhoenix.Comment

mix ecto.migrate
```
```rb
# edit web/router.ex
resources "/posts", PostController do
  post "/comment", PostController, :add_comment
end
```
```shell
mix phoenix.routes

#result
Generated appElixirPhoenix app
     page_path  GET     /                        AppElixirPhoenix.PageController :index
     post_path  GET     /posts                   AppElixirPhoenix.PostController :index
     post_path  GET     /posts/:id/edit          AppElixirPhoenix.PostController :edit
     post_path  GET     /posts/new               AppElixirPhoenix.PostController :new
     post_path  GET     /posts/:id               AppElixirPhoenix.PostController :show
     post_path  POST    /posts                   AppElixirPhoenix.PostController :create
     post_path  PATCH   /posts/:id               AppElixirPhoenix.PostController :update
                PUT     /posts/:id               AppElixirPhoenix.PostController :update
     post_path  DELETE  /posts/:id               AppElixirPhoenix.PostController :delete
post_post_path  POST    /posts/:post_id/comment  AppElixirPhoenix.PostController :add_comment
```
```rb
#add web/controllers/post_controller.ex
alias AppElixirPhoenix.Comment
plug :scrub_params, "comment" when action in [:add_comment]

def add_comment(conn, %{"comment" => comment_params, "post_id" => post_id}) do
  changeset = Comment.changeset(%Comment{}, Map.put(comment_params, "post_id", post_id))
  post = Post |> Repo.get(post_id) |> Repo.preload([:comments])

  if changeset.valid? do
    Repo.insert(changeset)

    conn
    |> put_flash(:info, "Comment added.")
    |> redirect(to: post_path(conn, :show, post))
  else
    render(conn, "show.html", post: post, changeset: changeset)
  end
end

def show(conn, %{"id" => id}) do
  post = Repo.get(Post, id) |> Repo.preload([:comments])
  changeset = Comment.changeset(%Comment{})
  render(conn, "show.html", post: post, changeset: changeset)
end
```

```erb
<%# create file  web/templates/post/comment_form.html.eex %>

<%= form_for @changeset, @action, fn f -> %>
  <%= if f.errors != [] do %>
    <div class="alert alert-danger">
      <p>Oops, something went wrong! Please check the errors below:</p>
      <ul>
        <%= for {attr, message} <- f.errors do %>
          <li><%= humanize(attr) %> <%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <label>Name</label>
    <%= text_input f, :name, class: "form-control" %>
  </div>

  <div class="form-group">
    <label>Content</label>
    <%= textarea f, :content, class: "form-control" %>
  </div>

  <div class="form-group">
    <%= submit "Add comment", class: "btn btn-primary" %>
  </div>
<% end %>

<%# edit file web/templates/post/show.html.eex %>
<%= render "comment_form.html", post: @post, changeset: @changeset,
action: post_post_path(@conn, :add_comment, @post) %>

<%# create file web/templates/post/comments.html.eex%>

<h3> Comments: </h3>
<table class="table">
  <thead>
    <tr>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
<%= for comment <- @post.comments do %>
    <tr>
      <td><%= comment.name %></td>
      <td><%= comment.content %></td>
    </tr>
<% end %>
  </tbody>
</table>
```
```rb
#edit web/models/post.ex
...
import Ecto.Query
...

def count_comments(query) do
   from p in query,
     group_by: p.id,
     left_join: c in assoc(p, :comments),
     select: {p, count(c.id)}
end

#edit web/controllers/post_controller.ex
def index(conn, _params) do
  posts = Post
  |> Post.count_comments
  |> Repo.all
  render(conn, "index.html", posts: posts)
end
```
```erb
<%# edit file web/templates/post/index.html.eex%>
<h2>Listing posts</h2>

<table class="table">
  <thead>
    <tr>
      <th>Title</th>
      <th>Body</th>
      <th>Count</th>

      <th></th>
    </tr>
  </thead>
  <tbody>
<%= for {post, count} <- @posts do %>
    <tr>
      <td><%= post.title %></td>
      <td><%= post.body %></td>
      <td><%= count %></td>

      <td class="text-right">
        <%= link "Show", to: post_path(@conn, :show, post), class: "btn btn-info btn-xs" %>
        <%= link "Edit", to: post_path(@conn, :edit, post), class: "btn btn-primary btn-xs" %>
        <%= link "Delete", to: post_path(@conn, :delete, post), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %>
      </td>
    </tr>
<% end %>
  </tbody>
</table>

<%= link "New post", to: post_path(@conn, :new), class: "btn btn-success" %>

```
```shell
mix phoenix.server
#http://localhost:4000/posts
```

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
