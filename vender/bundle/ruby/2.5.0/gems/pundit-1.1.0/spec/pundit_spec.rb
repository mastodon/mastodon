require "spec_helper"

describe Pundit do
  let(:user) { double }
  let(:post) { Post.new(user) }
  let(:customer_post) { Customer::Post.new(user) }
  let(:post_four_five_six) { PostFourFiveSix.new(user) }
  let(:comment) { Comment.new }
  let(:comment_four_five_six) { CommentFourFiveSix.new }
  let(:article) { Article.new }
  let(:controller) { Controller.new(user, action: "update") }
  let(:artificial_blog) { ArtificialBlog.new }
  let(:article_tag) { ArticleTag.new }
  let(:comments_relation) { CommentsRelation.new }
  let(:empty_comments_relation) { CommentsRelation.new(true) }
  let(:tag_four_five_six) { ProjectOneTwoThree::TagFourFiveSix.new(user) }
  let(:avatar_four_five_six) { ProjectOneTwoThree::AvatarFourFiveSix.new }

  describe ".authorize" do
    it "infers the policy and authorizes based on it" do
      expect(Pundit.authorize(user, post, :update?)).to be_truthy
    end

    it "works with anonymous class policies" do
      expect(Pundit.authorize(user, article_tag, :show?)).to be_truthy
      expect { Pundit.authorize(user, article_tag, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "raises an error with a query and action" do
      # rubocop:disable Style/MultilineBlockChain
      expect do
        Pundit.authorize(user, post, :destroy?)
      end.to raise_error(Pundit::NotAuthorizedError, "not allowed to destroy? this #<Post>") do |error|
        expect(error.query).to eq :destroy?
        expect(error.record).to eq post
        expect(error.policy).to eq Pundit.policy(user, post)
      end
    end
  end

  describe ".policy_scope" do
    it "returns an instantiated policy scope given a plain model class" do
      expect(Pundit.policy_scope(user, Post)).to eq :published
    end

    it "returns an instantiated policy scope given an active model class" do
      expect(Pundit.policy_scope(user, Comment)).to eq Comment
    end

    it "returns an instantiated policy scope given an active record relation" do
      expect(Pundit.policy_scope(user, comments_relation)).to eq comments_relation
    end

    it "returns an instantiated policy scope given an empty active record relation" do
      expect(Pundit.policy_scope(user, empty_comments_relation)).to eq empty_comments_relation
    end

    it "returns nil if the given policy scope can't be found" do
      expect(Pundit.policy_scope(user, Article)).to be_nil
    end

    it "returns nil if blank object given" do
      expect(Pundit.policy_scope(user, nil)).to be_nil
    end
  end

  describe ".policy_scope!" do
    it "returns an instantiated policy scope given a plain model class" do
      expect(Pundit.policy_scope!(user, Post)).to eq :published
    end

    it "returns an instantiated policy scope given an active model class" do
      expect(Pundit.policy_scope!(user, Comment)).to eq Comment
    end

    it "throws an exception if the given policy scope can't be found" do
      expect { Pundit.policy_scope!(user, Article) }.to raise_error(Pundit::NotDefinedError)
    end

    it "throws an exception if the given policy scope can't be found" do
      expect { Pundit.policy_scope!(user, ArticleTag) }.to raise_error(Pundit::NotDefinedError)
    end

    it "throws an exception if the given policy scope is nil" do
      expect do
        Pundit.policy_scope!(user, nil)
      end.to raise_error(Pundit::NotDefinedError, "unable to find policy scope of nil")
    end
  end

  describe ".policy" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy(user, post)
      expect(policy.user).to eq user
      expect(policy.post).to eq post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy(user, comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy(user, Post)
      expect(policy.user).to eq user
      expect(policy.post).to eq Post
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy(user, Comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq Comment
    end

    it "returns an instantiated policy given a symbol" do
      policy = Pundit.policy(user, :criteria)
      expect(policy.class).to eq CriteriaPolicy
      expect(policy.user).to eq user
      expect(policy.criteria).to eq :criteria
    end

    it "returns an instantiated policy given an array of symbols" do
      policy = Pundit.policy(user, [:project, :criteria])
      expect(policy.class).to eq Project::CriteriaPolicy
      expect(policy.user).to eq user
      expect(policy.criteria).to eq [:project, :criteria]
    end

    it "returns an instantiated policy given an array of a symbol and plain model instance" do
      policy = Pundit.policy(user, [:project, post])
      expect(policy.class).to eq Project::PostPolicy
      expect(policy.user).to eq user
      expect(policy.post).to eq [:project, post]
    end

    it "returns an instantiated policy given an array of a symbol and an active model instance" do
      policy = Pundit.policy(user, [:project, comment])
      expect(policy.class).to eq Project::CommentPolicy
      expect(policy.user).to eq user
      expect(policy.post).to eq [:project, comment]
    end

    it "returns an instantiated policy given an array of a symbol and a plain model class" do
      policy = Pundit.policy(user, [:project, Post])
      expect(policy.class).to eq Project::PostPolicy
      expect(policy.user).to eq user
      expect(policy.post).to eq [:project, Post]
    end

    it "returns an instantiated policy given an array of a symbol and an active model class" do
      policy = Pundit.policy(user, [:project, Comment])
      expect(policy.class).to eq Project::CommentPolicy
      expect(policy.user).to eq user
      expect(policy.post).to eq [:project, Comment]
    end

    it "returns correct policy class for an array of a multi-word symbols" do
      policy = Pundit.policy(user, [:project_one_two_three, :criteria_four_five_six])
      expect(policy.class).to eq ProjectOneTwoThree::CriteriaFourFiveSixPolicy
    end

    it "returns correct policy class for an array of a multi-word symbol and a multi-word plain model instance" do
      policy = Pundit.policy(user, [:project_one_two_three, post_four_five_six])
      expect(policy.class).to eq ProjectOneTwoThree::PostFourFiveSixPolicy
    end

    it "returns correct policy class for an array of a multi-word symbol and a multi-word active model instance" do
      policy = Pundit.policy(user, [:project_one_two_three, comment_four_five_six])
      expect(policy.class).to eq ProjectOneTwoThree::CommentFourFiveSixPolicy
    end

    it "returns correct policy class for an array of a multi-word symbol and a multi-word plain model class" do
      policy = Pundit.policy(user, [:project_one_two_three, PostFourFiveSix])
      expect(policy.class).to eq ProjectOneTwoThree::PostFourFiveSixPolicy
    end

    it "returns correct policy class for an array of a multi-word symbol and a multi-word active model class" do
      policy = Pundit.policy(user, [:project_one_two_three, CommentFourFiveSix])
      expect(policy.class).to eq ProjectOneTwoThree::CommentFourFiveSixPolicy
    end

    it "returns correct policy class for a multi-word scoped plain model class" do
      policy = Pundit.policy(user, ProjectOneTwoThree::TagFourFiveSix)
      expect(policy.class).to eq ProjectOneTwoThree::TagFourFiveSixPolicy
    end

    it "returns correct policy class for a multi-word scoped plain model instance" do
      policy = Pundit.policy(user, tag_four_five_six)
      expect(policy.class).to eq ProjectOneTwoThree::TagFourFiveSixPolicy
    end

    it "returns correct policy class for a multi-word scoped active model class" do
      policy = Pundit.policy(user, ProjectOneTwoThree::AvatarFourFiveSix)
      expect(policy.class).to eq ProjectOneTwoThree::AvatarFourFiveSixPolicy
    end

    it "returns correct policy class for a multi-word scoped active model instance" do
      policy = Pundit.policy(user, avatar_four_five_six)
      expect(policy.class).to eq ProjectOneTwoThree::AvatarFourFiveSixPolicy
    end

    it "returns nil if the given policy can't be found" do
      expect(Pundit.policy(user, article)).to be_nil
      expect(Pundit.policy(user, Article)).to be_nil
    end

    it "returns nil if the given policy is nil" do
      expect(Pundit.policy(user, nil)).to be_nil
    end

    describe "with .policy_class set on the model" do
      it "returns an instantiated policy given a plain model instance" do
        policy = Pundit.policy(user, artificial_blog)
        expect(policy.user).to eq user
        expect(policy.blog).to eq artificial_blog
      end

      it "returns an instantiated policy given a plain model class" do
        policy = Pundit.policy(user, ArtificialBlog)
        expect(policy.user).to eq user
        expect(policy.blog).to eq ArtificialBlog
      end

      it "returns an instantiated policy given a plain model instance providing an anonymous class" do
        policy = Pundit.policy(user, article_tag)
        expect(policy.user).to eq user
        expect(policy.tag).to eq article_tag
      end

      it "returns an instantiated policy given a plain model class providing an anonymous class" do
        policy = Pundit.policy(user, ArticleTag)
        expect(policy.user).to eq user
        expect(policy.tag).to eq ArticleTag
      end
    end
  end

  describe ".policy!" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy!(user, post)
      expect(policy.user).to eq user
      expect(policy.post).to eq post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy!(user, comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy!(user, Post)
      expect(policy.user).to eq user
      expect(policy.post).to eq Post
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy!(user, Comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq Comment
    end

    it "returns an instantiated policy given a symbol" do
      policy = Pundit.policy!(user, :criteria)
      expect(policy.class).to eq CriteriaPolicy
      expect(policy.user).to eq user
      expect(policy.criteria).to eq :criteria
    end

    it "returns an instantiated policy given an array of symbols" do
      policy = Pundit.policy!(user, [:project, :criteria])
      expect(policy.class).to eq Project::CriteriaPolicy
      expect(policy.user).to eq user
      expect(policy.criteria).to eq [:project, :criteria]
    end

    it "throws an exception if the given policy can't be found" do
      expect { Pundit.policy!(user, article) }.to raise_error(Pundit::NotDefinedError)
      expect { Pundit.policy!(user, Article) }.to raise_error(Pundit::NotDefinedError)
    end

    it "throws an exception if the given policy is nil" do
      expect { Pundit.policy!(user, nil) }.to raise_error(Pundit::NotDefinedError, "unable to find policy of nil")
    end
  end

  describe "#verify_authorized" do
    it "does nothing when authorized" do
      controller.authorize(post)
      controller.verify_authorized
    end

    it "raises an exception when not authorized" do
      expect { controller.verify_authorized }.to raise_error(Pundit::AuthorizationNotPerformedError)
    end
  end

  describe "#verify_policy_scoped" do
    it "does nothing when policy_scope is used" do
      controller.policy_scope(Post)
      controller.verify_policy_scoped
    end

    it "raises an exception when policy_scope is not used" do
      expect { controller.verify_policy_scoped }.to raise_error(Pundit::PolicyScopingNotPerformedError)
    end
  end

  describe "#pundit_policy_authorized?" do
    it "is true when authorized" do
      controller.authorize(post)
      expect(controller.pundit_policy_authorized?).to be true
    end

    it "is false when not authorized" do
      expect(controller.pundit_policy_authorized?).to be false
    end
  end

  describe "#pundit_policy_scoped?" do
    it "is true when policy_scope is used" do
      controller.policy_scope(Post)
      expect(controller.pundit_policy_scoped?).to be true
    end

    it "is false when policy scope is not used" do
      expect(controller.pundit_policy_scoped?).to be false
    end
  end

  describe "#authorize" do
    it "infers the policy name and authorizes based on it" do
      expect(controller.authorize(post)).to be_truthy
    end

    it "can be given a different permission to check" do
      expect(controller.authorize(post, :show?)).to be_truthy
      expect { controller.authorize(post, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "works with anonymous class policies" do
      expect(controller.authorize(article_tag, :show?)).to be_truthy
      expect { controller.authorize(article_tag, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "throws an exception when the permission check fails" do
      expect { controller.authorize(Post.new) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "throws an exception when a policy cannot be found" do
      expect { controller.authorize(Article) }.to raise_error(Pundit::NotDefinedError)
    end

    it "caches the policy" do
      expect(controller.policies[post]).to be_nil
      controller.authorize(post)
      expect(controller.policies[post]).not_to be_nil
    end

    it "raises an error when the given record is nil" do
      expect { controller.authorize(nil, :destroy?) }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe "#skip_authorization" do
    it "disables authorization verification" do
      controller.skip_authorization
      expect { controller.verify_authorized }.not_to raise_error
    end
  end

  describe "#skip_policy_scope" do
    it "disables policy scope verification" do
      controller.skip_policy_scope
      expect { controller.verify_policy_scoped }.not_to raise_error
    end
  end

  describe "#pundit_user" do
    it "returns the same thing as current_user" do
      expect(controller.pundit_user).to eq controller.current_user
    end
  end

  describe "#policy" do
    it "returns an instantiated policy" do
      policy = controller.policy(post)
      expect(policy.user).to eq user
      expect(policy.post).to eq post
    end

    it "throws an exception if the given policy can't be found" do
      expect { controller.policy(article) }.to raise_error(Pundit::NotDefinedError)
    end

    it "allows policy to be injected" do
      new_policy = OpenStruct.new
      controller.policies[post] = new_policy

      expect(controller.policy(post)).to eq new_policy
    end
  end

  describe "#policy_scope" do
    it "returns an instantiated policy scope" do
      expect(controller.policy_scope(Post)).to eq :published
    end

    it "throws an exception if the given policy can't be found" do
      expect { controller.policy_scope(Article) }.to raise_error(Pundit::NotDefinedError)
    end

    it "allows policy_scope to be injected" do
      new_scope = OpenStruct.new
      controller.policy_scopes[Post] = new_scope

      expect(controller.policy_scope(Post)).to eq new_scope
    end
  end

  describe "#permitted_attributes" do
    it "checks policy for permitted attributes" do
      params = ActionController::Parameters.new(action: "update", post: {
        title: "Hello",
        votes: 5,
        admin: true
      })

      expect(Controller.new(user, params).permitted_attributes(post)).to eq("title" => "Hello", "votes" => 5)
      expect(Controller.new(double, params).permitted_attributes(post)).to eq("votes" => 5)
    end

    it "checks policy for permitted attributes for record of a ActiveModel type" do
      params = ActionController::Parameters.new(action: "update", customer_post: {
        title: "Hello",
        votes: 5,
        admin: true
      })

      expect(Controller.new(user, params).permitted_attributes(customer_post)).to eq("title" => "Hello", "votes" => 5)
      expect(Controller.new(double, params).permitted_attributes(customer_post)).to eq("votes" => 5)
    end
  end

  describe "#permitted_attributes_for_action" do
    it "is checked if it is defined in the policy" do
      params = ActionController::Parameters.new(action: "revise", post: {
        title: "Hello",
        body: "blah",
        votes: 5,
        admin: true
      })

      expect(Controller.new(user, params).permitted_attributes(post)).to eq("body" => "blah")
    end

    it "can be explicitly set" do
      params = ActionController::Parameters.new(action: "update", post: {
        title: "Hello",
        body: "blah",
        votes: 5,
        admin: true
      })

      expect(Controller.new(user, params).permitted_attributes(post, :revise)).to eq("body" => "blah")
    end
  end

  describe "Pundit::NotAuthorizedError" do
    it "can be initialized with a string as message" do
      error = Pundit::NotAuthorizedError.new("must be logged in")
      expect(error.message).to eq "must be logged in"
    end
  end
end
