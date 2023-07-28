namespace TestProject1;

public class Tests
{
    [SetUp]
    public void Setup()
    {
    }

    [Test]
    public void Test1()
    {
        var principle = ClaimsPrincipalParser.Parse();
        Assert.That(principle.IsInRole("orders.admin"));
    }
}