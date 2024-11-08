import { Field, ID, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class DeviceQuery {

  @Field(() => ID)
  id: string;

  @Field()
  serialNumber: string;
  
  @Field()
  createdAt: Date;
}