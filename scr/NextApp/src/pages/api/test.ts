
import { NextApiRequest, NextApiResponse } from 'next';
import { DefaultAzureCredential } from "@azure/identity";
export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {

  try{

  
    const credential = new DefaultAzureCredential();
    var token = await credential.getToken(  "b73827cc-1587-46fb-8eac-a234662ccb0e");
    return res.status(200).json({token:token});
  }
  catch(error)
  {
    console.log(error);
    return res.status(500).end();
  }  // await fetch("https://ca-api-pqxgjxy6btr3i.jollypebble-8d13edbe.uksouth.azurecontainerapps.io/weatherforecast", {
    //     headers: {'Authorization': `bearer ${token}` }
    //   });

   
}
