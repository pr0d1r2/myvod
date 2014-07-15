# makes multiple asset hosts with auth possible
class AssetHost
  def call(source, request)
    sprintf(
      "https://myvod:myfancypassword@a%d.#{request.host}",
      (source.hash % 4)
    )
  end
end
