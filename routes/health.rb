configure_routes do
	get "/health" do
		content_type :text
		"gandalf is alive"
	end
end
