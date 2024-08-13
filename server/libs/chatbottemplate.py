class Chatbottemplate:
    def __init__(self, name, description, model):
        self.name = name
        self.description = description
        self.model = model
    def __str__(self):
        return f"Chatbot Name: {self.name}\nDescription: {self.description}"
starterchatbot = Chatbottemplate(
    name="starter",
    description="You are a helpfull assistant",
    model="llama3-8b-8192"
)
