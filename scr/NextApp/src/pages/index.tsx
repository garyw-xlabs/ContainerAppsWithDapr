import { useEffect, useState } from "react";

export default function Index() {

  const [message, setMessage ]= useState<string>("");

  useEffect(()=>{
      fetch("/api/test").then(x=>x.json()).then(x=>setMessage(x));


  },[]);


  return (
    <>
     {message}
    </>
  );
}
