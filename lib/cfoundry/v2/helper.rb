module CFoundry::V2::Helper
  def to_many_support(plural)
    singular = plural.to_s.sub(/s$/, "").to_sym

    alias_method :"remove_#{singular}_without_support", :"remove_#{singular}"
    define_method(:"remove_#{singular}") do |x|
      binding.pry
      result = self.__send__("remove_#{singular}_without_support", x)
      result.nil?
    end
  end
end
