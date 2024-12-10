import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { TelemetryQuery } from './telemetry.resolver';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { TransitTelemetryService } from '../services/transit-telemetry/transit-telemetry.service';
import { CreateTransitTelemetryDto } from '../dto/create-transit-telemetry.dto';


@ObjectType()
export class TransitTelemetryQuery extends TelemetryQuery {

  @Field()
  length: number;

  @Field()
  velocity: number;

  @Field()
  transitTime: number;
}


@Resolver(() => TransitTelemetryQuery)
export class TransitTelemetryResolver {
  constructor(
    private readonly transitTelemetryService: TransitTelemetryService,
  ) {}

  @Query(() => [TransitTelemetryQuery])
  @UseGuards(AdminGuard)
  async transitTelemetries() {
    return this.transitTelemetryService.findAll();
  }

  @Mutation(() => TransitTelemetryQuery)
  async createTransitTelemetry(
    @Args() input: CreateTransitTelemetryDto,
  ) {
    return this.transitTelemetryService.create(input);
  }
}

