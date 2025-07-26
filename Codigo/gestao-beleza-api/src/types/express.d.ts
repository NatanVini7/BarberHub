declare namespace Express {
  export interface Request {
    user?: {
      id_pessoa: number;
      email: string;
      nome: string;
    };
  }
}