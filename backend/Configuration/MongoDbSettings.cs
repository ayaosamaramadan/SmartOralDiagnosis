namespace MedicalManagement.API.Configuration
{
    public class MongoDbSettings
    {
        public string DatabaseName { get; set; } = "merncrud";
        public string ConnectionString { get; set; } = "mongodb+srv://ayaramadan2011:fxsIOnf4bQm39adR@crud.czs6s8q.mongodb.net/merncrud?retryWrites=true&w=majority&appName=crud";
    }
}
