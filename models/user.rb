class User < Sequel::Model(DB)
  many_to_one :blogplatform
  many_to_one :bloghosting

end
