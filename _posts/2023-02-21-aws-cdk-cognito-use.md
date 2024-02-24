---
title: "AWS CDK - Using Amazon Cognito Authentication and Authorization"
date: 2023-02-22 12:00:00 -0000
categories: aws devops cdk typescript
---

### Diagram

#### [Amazon Cognito Client Workflow (draw.io viewer)](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=Devops-IaC-AWS_CDK_Cognito-App.drawio#R7V1bc5vIEv41rjp7quLiKsmPWCgOWwJZEdpEednCCCN0Q0dCluDXn%2B6eQRcG20oiZe0NcVzAMMz09eumgfGV2pxt75beYmTHw2B6pUjD7ZVqXimKItU12GBLylpk6abBWsJlNORt%2B4ZelAV5R966jobB6qhjEsfTJFocN%2FrxfB74yVGbt1zGm%2BNuj%2FH0eNaFFwZCQ8%2F3pmLrl2iYjHirLEn7E5%2BCKBzxqRs6PzHz8s68YTXyhvHmoEltXanNZRwnbG%2B2bQZTlF4uF3bdx2fO7ghbBvPklAss27z%2FYm%2FcR03ZRLPFR82Svn2QdTbMkzddc445tUmai2AZr%2BfDAEeRrtTbzShKgt7C8%2FHsBrQObaNkNoUjGXaH3mpEffHgMZpOm%2FE0XsLxPJ7DFbci1ZyRp2CZBNuDJs7FXRDPgmSZQhd%2BtiHX2CXcphSNm9RmryBoZG2jA92oqsoNgxtFuBt7LzfY4aL7HjEKQgNtL3A3mpGB3QbDKPEepkFztfq8npJFX%2F8X2vl5c%2Bgl3pVqsEPl4%2BopvFJutyBWpXn%2FyVG%2BpbeK9%2BUvtTu70e571sYyjdAed%2FE3sj6Nkoc7Pbvv%2FRkPP33edKLG01Adqu25n7VnN%2Bm3tJHaprFpqziOBePCiFLwZTu9jxb1b7Pp6sGMx874Y6vb%2F9Z8dDdPvvpZf7jrU8%2Fb0fAuDL%2BZUuS6Lak9tjLLbKXtsbFx7nBrZU5k5FtGV09ixz2jeL68XyS90o8f907sl7fPF4kdaYpjhontGmtnPB233dbazroK9E%2FsVNvapr%2FuuIPEaWpaxwxD7G%2BPrcTuaWqnKW3b44Fsp1LWHvclm%2BgcbGALcgg1J90drx2zFdpN2GYh9DV0uAaubW2cSEuhDcfLnKwP5ycZ0uCMQ5CjvbbHA6nd03Qns0Pomznjv0zoq3eahtYeT7ZOiry1Nu1xNyUeXWsNupQGGfKryZ2eAfNMdBrLnKiW2YdtF8buwtZO2mN%2F4zQNoKm1BZqA90no4HVmCHyHmmUOoC2EXxjXDVXgRwfZqQ6N2wLekP5%2BSPSbsGVjbYB3lFvI5ZYwuXVDJjeD5MbmRbkZTE6pweWWH2sS6GxjNeEaotUAPkA%2FrqGATPbzZl3kQ4dxcFyN6cNS4HqUW7KT2xhlY4GMUAYT0LElwXhIg873ud3aG9KBO0lI1j2JdAY8ybCVYHyg08iAJxVkyewE6IB%2BcL6vMd5Dre2S7IA2ewu2gvJDXSooD5Ih2QDYAtiHPfa1YCYlND%2FJ1tCHkbaxzW9j6Js6TA6SjfowuzB%2FX%2B40Yd6xD7YyUGAODejRHZdkotlkS3YItBGNMB7IW5McnMvtAp8TCfwF5qX%2BktMkfSV7fwM6mN2qbddGmatAu2yTrAcof902%2BwnXO%2FkD0IJ63sDcuJUc02c26JK%2FSB3St8H9wkJ9SWQrzG915%2BsiabsToNsHHv8cwzUbsGe0KTjf36It2eCDDvLNfFlj8hzANRajJUXZ9TM2hwE%2BYQEPwK%2FbYjyAnbNzLZRHCnpi%2BgMeHdfG8WDfAh67Ou533D7sTxSUD8hKIrswLZIT7sPcGpMt2ogN4%2Fpbtg9%2BBeN2UMYm8ET6t2D%2BvkJ%2B5top6JvsHeSAcpEHYO%2BgPxh%2FQL6Nfsts2lbQ7h2XsIB0ZRMNIdK4QZ3kekC7xPMwBuFNx22hzW4ZrqHt2DBnF8eRQWZA%2F0Smc%2BQPhH0ys%2F2BHEykLcwPtHwEG%2FQlhqEwP%2BnHllC29hj1gHjGbNNxQzgON4xuC30acUJj2xDtVCXMBZ%2B2yc4t5tNmS8Ntx%2B2ibWWgZ7Drvoz6JV6wrUf%2BsmVjTfBcBj6gkJ1mfkbjjNHvUNch%2BQH6IvCJOlIY5nahv7YhvQN2oY3hPucv4fwxOTK7JPwG%2BWQoe%2BAxQR%2FHto5pMLsCTOBz5jaRMD5h7jFhE5P%2FmPAEbJrwXncIW42MeHTRj4F30lMr4zJh47lgd2OyTaRdRUyD69MOk8uWxaFQ6aBMx8iLAfI1OK9Eu8Z01SIM7XxCPwN7H9tgG5YMeIf2jHOoJC%2BUfTZAuhA7aA4aB%2FpCH53kQPgCugaabIbDW4bDloK4ArpDPUod0pm9JdqzAefb53JpyczmWqhL4McOCT%2FI52wN4zP4UIrxG3xD6SBuuwaTTTaQWa5B8Y7wzyG%2FQruxU6YrogvGtQizmH3ZyFfaZniN%2BIb6wZhBNB3wkRI%2BZhMaC%2FjBfir5VmYwnwFbBR%2FOmG0hf3%2BBn3Q1xCeH%2BOwibyqj15cRU1js8yl2OIRrocx8xd909sew7apMdzDX2FeYjlspiw0%2B2Bv6bl9l%2BObLxG9EtrDG2A1%2BzGwz69O8hDlkGxMZ%2B%2BS2BjJlNke2PgE%2F6XI8ANwfh9s25ROtkPzEJFzXnfHn2gPoFXjOSCeYb6SUx2AMwbFlJus%2B452weqKRHFls21KMhHjL9NdK2PiDkI2P8kc5oj4JfxnmZS3m2%2BSfPOZkqFuf4z3KTiJZshhGx0yWTchvoT%2FkVWSrvB%2FPPQ76RShHZkcsTtsSx2CZxcOJBDrHeA%2F6pliUdu4oT5Mpp0nR5qn%2FlnAuIx%2FVHRprIFHcSZlPYO7XIbkbuA%2F2CDIkPslWNEavdWBvfe3ALoEWG%2FWudggrbaZHd4S60Vl8B1%2BaAW04tot20uL550BieZRPPkQ%2BjViB82VsPna%2BS9jEYiDmekS3wvIGm8V6hnWaw20P6IB5DEbLGGPBgNuZnWE8AflQTEN%2BiTYXcy60Tw1tBDEsdVzCHAnmwHkYjjNc4zkj%2BbdqYz%2FKb%2FBcS4KxNxRvM8BK8BWixx1kfJ%2FFDsAStGkH71UwTzL9hOUTEssnIH9k8cRiuSXpqs%2FvGRDvKZ9gNmSiHba2zG8xn4C5030u7bjcT3AeoM3%2BYpN%2FAE%2FSHre6gBV5zoz5lYX5HPTjOsiYLwE9KrvGlnlOo%2FAclZ03MfZQjs98CuOj20X5ok%2BlTIdWSvkC5QndDcMX3O%2FLeU5COD1mOqX7Dpf8TGN5n09zOBnLV3iewfLJHO%2BYX0J8ADuE%2BR3Cg89jyjkoV4CchXIU8hFmo1mX5ysGy1ewjfmQkuc37Pq%2ByuIu49nOc5dcRpCzEMYQr12VctQe5kDsnspm8UeGe4GaFTXw7rV5kw1nPuydqfKQX8IrDzVVKDw0SuoOu2LR2esO2pmrNxcq2OT8c7HpotgUrVYiN%2FVSclMFuRlfetBgzBbT6DEVqzmTIPFHXIaLOJonRJF%2BC%2F%2BBxib71aFrE1uuFb2ksaytLjbKYjfYyGUzFBvL2upioyx2w6Oc6uPGsra6LlJcvFouuVouXA3%2F1dt4nUyjedDcFXBRxo%2FxPMkN8UpR4ecjqvfIQKHdNFVNa0L7KlnGk%2BDgzCP9OyxI4rBos5HvTdveQzC9j1dREsVzOPcQJ0k8O%2BhgTKMQTyQxeojHj3zwgWBZcBmglJetZSU%2F5paDU3qrBWPrMdoiHbd5ZXC2DbFmfu1tVtr1MljF66UfWD7ScwuHbO%2B4l8fN8yxeeaM2jryyLgleWW%2BITpm3nd0nFdEnZ14GQlCknlp55DvxyLphyHLtt%2FHIlXoeZ6zpBWfU%2FllnFB8LfQ48EFrRDYG95Fj6gmaKCpxFwyFeXpqLHGcr58g9VO1IsLJWFyRbk0qeFV0q9agJku0lHggI2j5G%2BGDo3Ym4fnNsu2pJVlwiYeVSEq4LEu6vQEyKdB%2FH0yqQvJNA8puldn4czqMkvkxqp9RE0Pul4aQhuKQ1BPaiJK3csnLL39UttVrtn3XLG8EtBT%2F8rvLROZIJvX4ko1pNzISVm5J0QtYvlU%2Fkr6IdiKmTjCijYFWjXrB8ivxfnrod2n3RL7RzaaPxqjbkX5o%2By7KgjF2ZwLi3rpTaFEX%2BANqphbh35yXBxqtKeu8lwLTqsl6%2F%2FW0CjLeI%2Fg65iZ7HZRvKkcvWZdFl9ZIgo18qyMhVYe%2Ff4JdVYe%2BH3LGRl9V37iiW2Wslz77ytvO743PPvtre7GHoVf74TvyxZdbxufLv4o9TZp3nuQ%2BrneCTJc%2Fx87bz%2B6T4HD8PkcV0tslvSItuWmpKlzaAEn2qB7fMBYs1zFqjgZkddB5Gwd7Kz%2FimQaHar5bcr%2BT3iUfJz6U%2BDMmL3ALaNqfxeihosRRfBWwt4qqAqcd4KmBVEacEjDpGSwFQi6grQPMxegsAWkRZAYpfxMdnrOfALMtunV%2FDKoCcxIO5lnwM0kSwbD0FTCGsz3TqLVbRw%2B6qZeCvl6voKfgcrNjg0nMwF8LN%2B4LIL4M3Ovs37P7to2H87ZHbC9BeGgy4AF5232nwSCOCVKJ52KYjU30p3hyBxxl8U9OOUbcUdEt8s3GxWkJe7jpwzuYUTeuEJOjANDgSso%2F7BNg9hMsjdXK1FUBSl%2FAH2qcFmBYqRt%2BJ46W%2BJIB70XTjx8fID66HARW4rmeeDwZKIjqPTRybhFrXCGMKZlFW7qvfXOuXMosT3qoL5kMDvy5F2U291SrySb%2FeMhGbDyzguIAHclumX%2FHgWpLkvGFADepNPW8wt4f9zfTw6D5YRsA1wdaLfspyrBOcAXgIg%2BSljqxfMDz6cFZU8Wshl7ctg6mXAIIeUVumUz7DPXrfQcQvWlABLBjf%2FKK9YQjjqIV3FIVyMpOLMBCoG4uLu248gj9Pr14AQb1gr2zAvfXuJPoTBi0%2BfpOv4fguQMJeef0A9UxQ86OF7CWGRm8fM49zHLPUaF%2F2yyK87L7%2B5rNcHX5gXQY7kIVI0nGZLP%2BE9yfNMS925VcAfq6CpKDi8yj1hC%2B3z4xSxwilnxWfXoWd%2BpuCnd2ryTnu3Pwg7shFANMugzvCPDfS99El1X4BUIkPJBUEKmOdjPB1Ad9LAuR5DndOUkjolUBGVXKb%2FLiEVAjusvK7ZemlV4BegTieOv8CgMtd%2BgwAp9byROonLf2DrBdKkRfENPHluMtg2o%2FDUP788Y3ikKYUsuJTcUh4bAQ21Kih26u1hpp7%2F6VRKSf%2FVFSqa%2BrlUUkVHzlrhEo%2B3BKtrsS3AED3oHpw2mVAbzl505WIUP%2BJEY%2F%2B%2FOLuQUx6pDZ6jC0tguUsAjuO56s%2F3i5i5Q57BsTSG9p5crAPhRz7Q2GEC%2BKX%2BOrpZfDrjeRkjbeNhfK5crLaZXKyulJO8LMYXeiv%2F4qbx1yoBzatIvq1tv7Im%2BNiRUX4IjR8EfvylmH0dOQctf%2BtcTWsW3xv6gMHMwN6cDzbd8gH4kC7T%2FMOXitdUKonCTj7Rz47iIMIyGl6uze%2BOaz8NMp%2BkK7lXSw%2F751vvfAI5Swo%2B2n7eaT1sun9pGXOb9edeeex%2FUEMx4Lufvaj16NVzJ7Fx%2B%2Boc%2BqF6lKDD%2FHqW43SGZ5MlUpRLzX4%2FJFIvExGcRjPvWlr31oIQvs%2B7RhLzCSscZAkKX%2FQ4q3pMeApL4gelidLyVXEkFTaTz0xJJ1s7T8lZNEyq3XhqnXhqnXhqnXhqnXhqnXhqnXhqnXhqnXhqnXhqnXhqnXhqnXhqnXhqnXh3um6cFqtWN6pX4uvsdUUsb5TfF3pbJWH2vsq76gnlne0N1XeKfl6rSrvVOWdqrxTlXeq8k5V3qnKO1V5pyrvVOWdqrxTlXeq8k5V3qnKO%2B%2BzvKPXjlfBegPlHa2qPFSVh6ryUFUeqspDVXmoKg9V5aGqPFSVh6ryUFUeqspDVXmoKg%2F%2FlspDrVYrVB4a%2F2zdQVxJRnzPZP%2BBq7g0W%2BEz1m2UfD3YP%2FiIFY7237DiwdEnrF%2F5cLtPX3cHz3z4evRBFx7ce0kSLOfUokgnv7xSvibAiS%2BvvK2lA%2BrFb9JuCkOc%2BrlsQy4OVPhm7ZnPZc%2F1PaC4aIixWAhm%2Beb%2FjJKWO3L%2BR1u0El%2B%2F0FL75eYqfvnbjsNo3oxnC3DskmXy3ryMde3mVRnv%2FlrrrxFyyd8zWCcjvpjE%2B5NwrVAr%2F8et%2BPuWZDg1YsmHEevFeHVC5PnR1RxOilgvRaLXV7t50xFr95fmvnuxm5tixDptgYfXIxYcLmNcomDfHdfRtOMhriPQ%2Bj8%3D){:target="_blank" rel="noopener"}

![Amazon Cognito Client Workflow]({{ site.github-content }}/devops/Devops-IaC-AWS_CDK_Cognito-App.drawio.svg?raw=true)

In my previous blog post, ["AWS CDK - Testing Amazon Cognito Authentication and Authorization"](aws-cdk-cognito-testing.html){:target="_blank" rel="noopener"}, I go-over testing the Auth Service stack, ensuring we receive back proper JWT tokens. I will now illustrate how to make use of the Auth Service stack within a hypothetical React application.

### Components

| Component | File Name | Description |
| --------- | --------- | ----------- |
| Authentication Service | AuthService.ts | Perform user challenge and authentication and authorization, returning JWT Tokens and AWS Credentials. |
| Login Component | LoginComponent.tsx | A very simple react component, which will perform the authentication, using the AuthService.ts service file. |
| Frontend Router | App.tsx | A very simple React frontend web application which will present a router, with '/login' making a call to LoginComponent.tsx.|

### Overview
The components are stored and bundled into an S3 Bucket and served as static content. Hypothetically, in addition to the Authentication Service, APIs called via API Gateway can be used to trigger Lambda functions, which can make use of the custom scopes as injected by a Cognito Identity Pool client and/or, the ID Token used as an Authorization header to the API, whereby API Gateway can desingate Cognito as an Authorizer to check for access. We may also parse group memberships within the token to determine whether certain API methods are allowed or not.

### Breaking It Down

#### Authentication Service
[GitHub Gist](https://gist.github.com/Adam-Lechnos/fc1a9ead7491b8435be9fe1777c36b98)

The authentication service code has been discussed at length, from the previous two blog posts, we perform a deep dive into creating a testing the auth service stack. The code here is identical to what we previously covered went over.

Some additional changes made to the AuthService file are as follows:

```
private async generateTemporaryCredentials() {
    const cognitoIdentityPool = `cognito-idp.${awsRegion}.amazonaws.com/${AuthStack.SpaceUserPoolId}`;
    const cognitoIdentity = new CognitoIdentityClient({
        credentials: fromCognitoIdentityPool({
            clientConfig: {
                region: awsRegion
            },
            identityPoolId: AuthStack.SpaceIdentityPoolId,
            logins: {
                [cognitoIdentityPool]: this.jwtToken!
            }
        })
    });
    const credentials = await cognitoIdentity.config.credentials();
    return credentials;
}
```
* The function above will use Cognito for access to the temporary AWS Credentials by supplying the JWT Auth Token. When the Web Application wants to perform a task on behalf of the user, such as uploading a photo to an S3 bucket, these credentials may be used.
  * The Assumed IAM Role for the Credentials will be the Authenticated default for Cognito. Any additional Cognito groups with designated IAM roles will also provide those permissions as well.
    * This is useful for delineating group permissions according to membership type, such as premium vs non-premium members.

#### Login Component
[GitHub Gist](https://gist.github.com/Adam-Lechnos/d8f8dc6d244b49fe3c6969ced5151743)

Here we break down the code used for performing the login and ensuring the user authenticated. We make extensive use of [State Hooks](https://react.dev/reference/react/hooks#state-hooks), which provide a clean way to initialize and update states across our web app.

```
type LoginProps = {
  authService: AuthService;
  setUserNameCb: (userName: string) => void;
};

export default function LoginComponent({ authService, setUserNameCb }: LoginProps) {
  const [userName, setUserName] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [errorMessage, setErrorMessage] = useState<string>("");
  const [loginSuccess, setLoginSuccess] = useState<boolean>(false);
```
* A function labeled,`LoginComponent` is created with one argument of type `LoginProps`. We defined the 'type' above, via the `type LoginProps` line.
  * Hence, this one argument will require a type which contains two components, 'authService' of type 'AuthService', and 'setUserNameCb' which is a callback function that takes a string without a return.
* We then initialize four State Hooks, each empty (and boolean as false) accessible via `userName`, `password`, `errorMessage`, and `loginSuccess`.
  * We can now set and use these variables by calling their 'setIndex' for setting the state, and referencing each variable where they each apply.

```
const handleSubmit = async (event: SyntheticEvent) => {
    event.preventDefault();
    if (userName && password) {
      const loginResponse = await authService.login(userName, password);
      const userName2 = authService.getUserName();
      if (userName2) {
        setUserNameCb(userName2);
      }

      if (loginResponse) {
        setLoginSuccess(true);
      } else {
        setErrorMessage("invalid credentials");
      }
    } else {
      setErrorMessage("UserName and password required!");
    }
  };
```
* The `handleSubmit` will take in one 'event' argument, a SyntheticEvent type which will be explained further below. This will grab the end-user action and perform the following:
  * If the user provided a username and password within the login form, the `loginResponse` variable will perform a call to the `authService.login` method, which was supplied by the 'LoginProps' type argument.
  * The method is supplied with the username and password, now being handed off to the Authentication Service component, will use Cognito to authenticate the user, then store the JWT tokens and make available the AWS Credentials.
  * The 'username2' variable will contain the username if the `authService.getUserName()` succeeds. If set, set as the argument to the `setUserNameCb` callback supplied to the 'LoginProps' type argument.
  * If `LoginResponse` was populated from the Auth Service login function, the State Hook  for `loginSuccess` variable gets called, `setLoginSuccess`, setting it to 'true'.

```
  return (
    <div role="main">
      {loginSuccess && <Navigate to="/profile" replace={true} />}
      <h2>Please login</h2>
      <form onSubmit={(e) => handleSubmit(e)}>
        <label>User name</label>
        <input
          value={userName}
          onChange={(e) => setUserName(e.target.value)}
        />
        <br />
        <label>Password</label>
        <input
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          type="password"
        />
        <br />
        <input type="submit" value="Login" />
      </form>
      <br />
      {renderLoginResult()}
    </div>
  );
```
* The Login Component returns the React frontend component for logging in, the form for supplying the username and password, and a Submit button to set the variables for username and password via the Set Hooks, `setUsername` and `setPassword`.
  * Notice the event being supplied to the 'handleSubmit' function 'event' parameter as `e`, which carries over each of their respective `value` vars supplied by the form to an anonymous function, which is supplied as `e.target.value` to each of the State Hooks' 'setIndexes', such as `setUserName(e.target.value)`.
  * CLicking 'Submit' triggers the 'setIndex' calls to the `handleSubmit` function.

#### Application Router
[GitHub Gist](https://gist.github.com/Adam-Lechnos/5e2049715eb7ffac7162af4303017e65)

Finally, the Application Router presents the code required for rendering a component based on the URL path.

```
const authService = new AuthService();
const dataService = new DataService(authService);

function App() {
  const [userName, setUserName] = useState<string | undefined>(undefined);

  const router = createBrowserRouter([
    {
      element: (
        <>
          <NavBar userName={userName}/>
          <Outlet />
        </>
      ),
      children:[
        {
          path: "/",
          element: <div>Hello world!</div>,
        },
        {
          path: "/login",
          element: <LoginComponent authService={authService} setUserNameCb={setUserName}/>,
        },
        {
          path: "/profile",
          element: <div>Profile page</div>,
        },
        {
          path: "/createSpace",
          element: <CreateSpace dataService={dataService}/>,
        },
        {
          path: "/spaces",
          element: <Spaces dataService={dataService}/>,
        },
      ]
    },
  ]);
```
* Here, we have a router which will perform a component depending on where the user is redirected. Their would be a navbar at the entry point, which then routes to each of the provided `path` values. Based on the 'path', the `element` is dynamically rendered.
* For `path: "/login"`, the LoginComponent service is called as follows: `LoginComponent authService={authService} setUserNameCb={setUserName}`
  * Notice the argument adheres to the `LoginProps` type declared in the LoginComponents above, with the `authService` being the imported `AuthService()` function assigned to the variable at the top of the code, along with,
  * `setUserNameCb`, which is a callback function, called back by the LoginComponent when its username form field is set. The callback triggers the 'setIndex' for the `userName` State Hook: `const [userName, setUserName] = useState<string | undefined>(undefined)`.
  * Recall the LoginComponent's function decleration, which declared the paramters as `function LoginComponent({ authService, setUserNameCb }: LoginProps)`.
    * `setUserNameCb` in LoginComponent is the triggers the `setUserName` 'setIndex' in App.tsx, as it's called back.
    * LoginProps type declared 'setUserNameCb' as an anonymous function, returning void as: `setUserNameCb: (userName: string) => void`