import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { DeviceQuery } from './device.resolver';
import { CreateDynamicGuardDto } from '../dto/create-dynamic-guard.dto';
import { DynamicGuardService } from '../services/dynamic-guard/dynamic-guard.service';


@ObjectType()
export class DynamicGuardQuery extends DeviceQuery {

  @Field()
  userId: string;
}


@Resolver(() => DynamicGuardQuery)
export class DynamicGuardResolver {
  constructor(
    private readonly dynamicGuardService: DynamicGuardService,
  ) {}

  @Query(() => [DynamicGuardQuery])
  @UseGuards(AdminGuard)
  async dynamicGuard() {
    return this.dynamicGuardService.findAll();
  }

  @Mutation(() => DynamicGuardQuery)
  @UseGuards(AdminGuard)
  async createDynamicGuard(
    @Args() input: CreateDynamicGuardDto,
  ) {
    return this.dynamicGuardService.create(input);
  }
}

