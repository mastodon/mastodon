# bcrypt-ruby

An easy way to keep your users' passwords secure.

* http://github.com/codahale/bcrypt-ruby/tree/master

[![Build Status](https://travis-ci.org/codahale/bcrypt-ruby.png?branch=master)](https://travis-ci.org/codahale/bcrypt-ruby)

## Why you should use `bcrypt()`

If you store user passwords in the clear, then an attacker who steals a copy of your database has a giant list of emails
and passwords. Some of your users will only have one password -- for their email account, for their banking account, for
your application. A simple hack could escalate into massive identity theft.

It's your responsibility as a web developer to make your web application secure -- blaming your users for not being
security experts is not a professional response to risk.

`bcrypt()` allows you to easily harden your application against these kinds of attacks.

*Note*: JRuby versions of the bcrypt gem `<= 2.1.3` had a [security
vulnerability](http://www.mindrot.org/files/jBCrypt/internat.adv) that
was fixed in `>= 2.1.4`. If you used a vulnerable version to hash
passwords with international characters in them, you will need to
re-hash those passwords. This vulnerability only affected the JRuby gem.

## How to install bcrypt

    gem install bcrypt

The bcrypt gem is available on the following ruby platforms:

* JRuby
* RubyInstaller 1.8, 1.9, 2.0, 2.1, and 2.2 builds on win32
* Any 1.8, 1.9, 2.0, 2.1, 2.2, or 2.3 Ruby on a BSD/OS X/Linux system with a compiler

## How to use `bcrypt()` in your Rails application

*Note*: Rails versions >= 3 ship with `ActiveModel::SecurePassword` which uses bcrypt-ruby.
`has_secure_password` [docs](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)
implements a similar authentication strategy to the code below.

### The _User_ model

    require 'bcrypt'

    class User < ActiveRecord::Base
      # users.password_hash in the database is a :string
      include BCrypt

      def password
        @password ||= Password.new(password_hash)
      end

      def password=(new_password)
        @password = Password.create(new_password)
        self.password_hash = @password
      end
    end

### Creating an account

    def create
      @user = User.new(params[:user])
      @user.password = params[:password]
      @user.save!
    end

### Authenticating a user

    def login
      @user = User.find_by_email(params[:email])
      if @user.password == params[:password]
        give_token
      else
        redirect_to home_url
      end
    end

### If a user forgets their password?

    # assign them a random one and mail it to them, asking them to change it
    def forgot_password
      @user = User.find_by_email(params[:email])
      random_password = Array.new(10).map { (65 + rand(58)).chr }.join
      @user.password = random_password
      @user.save!
      Mailer.create_and_deliver_password_change(@user, random_password)
    end

## How to use bcrypt-ruby in general

    require 'bcrypt'

    my_password = BCrypt::Password.create("my password")
      #=> "$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa"

    my_password.version              #=> "2a"
    my_password.cost                 #=> 10
    my_password == "my password"     #=> true
    my_password == "not my password" #=> false

    my_password = BCrypt::Password.new("$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa")
    my_password == "my password"     #=> true
    my_password == "not my password" #=> false

Check the rdocs for more details -- BCrypt, BCrypt::Password.

## How `bcrypt()` works

`bcrypt()` is a hashing algorithm designed by Niels Provos and David Mazières of the OpenBSD Project.

### Background

Hash algorithms take a chunk of data (e.g., your user's password) and create a "digital fingerprint," or hash, of it.
Because this process is not reversible, there's no way to go from the hash back to the password.

In other words:

    hash(p) #=> <unique gibberish>

You can store the hash and check it against a hash made of a potentially valid password:

    <unique gibberish> =? hash(just_entered_password)

### Rainbow Tables

But even this has weaknesses -- attackers can just run lists of possible passwords through the same algorithm, store the
results in a big database, and then look up the passwords by their hash:

    PrecomputedPassword.find_by_hash(<unique gibberish>).password #=> "secret1"

### Salts

The solution to this is to add a small chunk of random data -- called a salt -- to the password before it's hashed:

    hash(salt + p) #=> <really unique gibberish>

The salt is then stored along with the hash in the database, and used to check potentially valid passwords:

    <really unique gibberish> =? hash(salt + just_entered_password)

bcrypt-ruby automatically handles the storage and generation of these salts for you.

Adding a salt means that an attacker has to have a gigantic database for each unique salt -- for a salt made of 4
letters, that's 456,976 different databases. Pretty much no one has that much storage space, so attackers try a
different, slower method -- throw a list of potential passwords at each individual password:

    hash(salt + "aadvark") =? <really unique gibberish>
    hash(salt + "abacus")  =? <really unique gibberish>
    etc.

This is much slower than the big database approach, but most hash algorithms are pretty quick -- and therein lies the
problem. Hash algorithms aren't usually designed to be slow, they're designed to turn gigabytes of data into secure
fingerprints as quickly as possible. `bcrypt()`, though, is designed to be computationally expensive:

    Ten thousand iterations:
                 user     system      total        real
    md5      0.070000   0.000000   0.070000 (  0.070415)
    bcrypt  22.230000   0.080000  22.310000 ( 22.493822)

If an attacker was using Ruby to check each password, they could check ~140,000 passwords a second with MD5 but only
~450 passwords a second with `bcrypt()`.

### Cost Factors

In addition, `bcrypt()` allows you to increase the amount of work required to hash a password as computers get faster. Old
passwords will still work fine, but new passwords can keep up with the times.

The default cost factor used by bcrypt-ruby is 10, which is fine for session-based authentication. If you are using a
stateless authentication architecture (e.g., HTTP Basic Auth), you will want to lower the cost factor to reduce your
server load and keep your request times down. This will lower the security provided you, but there are few alternatives.

To change the default cost factor used by bcrypt-ruby, use `BCrypt::Engine.cost = new_value`:

    BCrypt::Password.create('secret').cost
      #=> 10, the default provided by bcrypt-ruby

    # set a new default cost
    BCrypt::Engine.cost = 8
    BCrypt::Password.create('secret').cost
      #=> 8

The default cost can be overridden as needed by passing an options hash with a different cost:

    BCrypt::Password.create('secret', :cost => 6).cost  #=> 6

## More Information

`bcrypt()` is currently used as the default password storage hash in OpenBSD, widely regarded as the most secure operating
system available.

For a more technical explanation of the algorithm and its design criteria, please read Niels Provos and David Mazières'
Usenix99 paper:
http://www.usenix.org/events/usenix99/provos.html

If you'd like more down-to-earth advice regarding cryptography, I suggest reading <i>Practical Cryptography</i> by Niels
Ferguson and Bruce Schneier:
http://www.schneier.com/book-practical.html

# Etc

* Author  :: Coda Hale <coda.hale@gmail.com>
* Website :: http://blog.codahale.com
